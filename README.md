# fluent-plugin-factor

## Requirements

| fluent-plugin-factor | fluentd    |
|----------------------|------------|
| >= 1.0.0             | >= v0.14.0 |
| <  1.0.0             | <  v0.14.0 |

## Installation
```
gem install fluent-plugin-factor
```

## Usage
Example:
```
<source>
  @type factor
  tag factor
  run_at_start
  run_interval 1h
</source>
```

output as follows every hour:
```
factor: {
  "hostname": "test-machine",
  "operatingsystem": {
    "name": "CentOS",
    "version": "6.8",
    "family": "RedHat"
  },
  "kernel": {
    "name": "Linux",
    "release": "2.6.32-642.11.1.el6.x86_64"
  },
  "processors": {
    "models": [
      "Intel(R) Xeon(R) CPU           X5650  @ 2.67GHz",
      "Intel(R) Xeon(R) CPU           X5650  @ 2.67GHz"
    ],
    "count": 2,
    "physicalcount": 1
  },
  "memory": {
    "size": "995.95"
  },
  "volumes": [
    {
      "name": "sda",
      "size": 10
    }
  ],
  "interfaces": [
    {
      "name": "eth0",
      "ipaddress": "10.8.0.201",
      "netmask": "255.255.252.0",
      "macaddress": "00:0C:29:C5:26:8A"
    }
  ],
  "is_virtual": true
}
```

## Configuration

### tag (required)
The tag of the event.

### run_interval
The gathering interval. If enable this option, the gathering function is not execute when starting fluentd. If you want, enable  `run_at_start` option.

### run_at_start
If set to true, gathering at start fluentd.

### run_at_shutdown
If set to true, gathering at shutdown fluentd.

### \<factors\>
If you want to gather only specific factor, you can use `<factors>` section.
```
<source>
  @type factor
  tag factor
  <factors>
    memory true
    volumes true
  </factors>
</source>
```
In this case, the output is only memory and volumes.
```
factor: {
  "memory": {
    "size": "995.95"
  },
  "volumes": [
    {
      "name": "sda",
      "size": 10
    }
  ]
}
```
The available keys as follows:
- hostname
- operatingsystem
- kernel
- processors
- memory
- volumes
- interfaces
- is_virtual
