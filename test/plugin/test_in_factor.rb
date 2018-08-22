require "helper"

class FactorInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %{
    tag test
  }

  def create_driver(conf = CONFIG)
    Fluent::Test::InputTestDriver.new(Fluent::FactorInput).configure(conf)
  end

  def test_emit
    d = create_driver
    d.run
    p d.emits
  end
end
