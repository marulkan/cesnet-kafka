# == Class kafka::server::config
#
# Configure Kafka broker
#
class kafka::server::config {
  include ::stdlib

  $environment = $::kafka::_environment
  file { $::kafka::envfile_server:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('kafka/env.sh.erb'),
  }

  $properties = $::kafka::_properties
  $properties_list = keys($::kafka::_properties)
  file { "${kafka::confdir}/server.properties":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('kafka/properties.erb'),
  }

  # fix buggy startup script (BigTop 1.2.0)
  file_line { 'kafka-server-start.sh':
    ensure => present,
    path   => '/usr/lib/kafka/bin/kafka-server-start.sh',
    line   => ". ${::kafka::envfile_server}",
    after  => '^#.*/bin/bash',
  }

  if $::kafka::realm and $::kafka::realm != '' {
    $keytab = $::kafka::keytab
    $principal = "kafka/${::fqdn}@${::kafka::realm}"

    file { $keytab:
      owner => 'kafka',
      group => 'kafka',
      mode  => '0400',
    }

    file { "${::kafka::confdir}/jaas.conf":
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('kafka/jaas.conf.erb'),
    }
  } else {
    file { "${::kafka::confdir}/jaas.conf":
      ensure => 'absent',
    }
  }
}
