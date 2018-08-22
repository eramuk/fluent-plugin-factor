require "fluent/plugin/input"
require "fluent/config/error"
require "facter"
require "json"

module Fluent::Plugin
  class FactorInput < Input
    Fluent::Plugin.register_input('factor', self)

    config_param :tag, :string
    config_param :run_interval, :time, default: nil
    config_param :run_at_start, :bool, default: nil
    config_param :run_at_shutdown, :bool, default: nil
    config_section :factors, multi: false do
      config_param :hostname, :bool, default: false
      config_param :operatingsystem, :bool, default: false
      config_param :kernel, :bool, default: false
      config_param :processors, :bool, default: false
      config_param :memory, :bool, default: false
      config_param :volumes, :bool, default: false
      config_param :interfaces, :bool, default: false
      config_param :is_virtual, :bool, default: false
    end

    def configure(conf)
      super

      if !@run_interval && @run_at_start
        raise ConfigError, "'run_at_start' option needs 'run_interval' option"
      end

      factor_keys = [
        "hostname",
        "operatingsystem",
        "kernel",
        "processors",
        "memory",
        "volumes",
        "interfaces",
        "is_virtual",
      ]

      @factors = @factors.to_h

      if @factors.empty?
        factor_keys.each do |key|
          @factors[key] = true
        end
      end

      if @factors.select { |k,v| v == true }.empty?
        raise ConfigError, "one or more factor are required"
      end
    end

    def start
      super
      if @run_interval
        @finished = false
        @thread = Thread.new(&method(:run_periodic))
      else
        @thread = Thread.new(&method(:run))
      end
    end

    def before_shutdown
      super
      gather_factor if @run_at_shutdown
    end

    def shutdown
      super
      @thread.terminate
      @thread.join
    end

    def run
      gather_factor
    end

    def run_periodic
      gather_factor if @run_at_start
      while true
        sleep @run_interval
        gather_factor
      end
    end

    def gather_factor
      begin
        record = {}
        @factors.each do |factor, enabled|
          record[factor] = send(factor) if enabled
        end
        router.emit(@tag, Fluent::EventTime.now, record)
      rescue => e
        router.emit_error_event(@tag, Fluent::EventTime.now, record, e)
      end
    end

    def hostname
      Facter.value(:hostname)
    end

    def operatingsystem
      {
        "name" => Facter.value(:operatingsystem),
        "version" => Facter.value(:operatingsystemrelease),
        "family" => Facter.value(:osfamily),
      }
    end

    def kernel
      {
        "name" => Facter.value(:kernel),
        "release" => Facter.value(:kernelrelease),
      }
    end

    def processors
      Facter.value(:processors)
    end

    def memory
      {
        "size" => Facter.value(:memorysize_mb )
      }
    end

    def volumes
      volumes = []
      blockdevice_names = Facter.value(:blockdevices).split(/,/)
      blockdevice_names.each do |device_name|
        next if device_name !~ /(hd.*|sd.*|md.*)/
        volumes.push({
          "name" => device_name,
          "size" => Facter.value("blockdevice_#{device_name}_size") / 1024 / 1024 / 1024,
        })
      end
      volumes
    end

    def interfaces
      interfaces = []
      interface_names = Facter.value(:interfaces).split(/,/)
      if interface_names
        interface_names.each do |if_name|
          next if if_name == "lo"
          interfaces.push({
            "name" => if_name,
            "ipaddress" => Facter.value("ipaddress_#{if_name}"),
            "netmask" => Facter.value("netmask_#{if_name}"),
            "macaddress" => Facter.value("macaddress_#{if_name}"),
          })
        end
      end
      interfaces
    end

    def is_virtual
      Facter.value(:is_virtual)
    end
  end
end
