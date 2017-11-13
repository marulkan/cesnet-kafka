# == Class kafka::client::config
#
# Stub class
#
class kafka::client::config {
  $environment = $::kafka::_environment['client']
  file { '/etc/profile.d/kafka.sh':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('kafka/env.sh.erb'),
  }
  file { '/etc/profile.d/kafka.csh':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('kafka/env.csh.erb'),
  }

  $properties = $::kafka::_properties
  $properties_list = $::kafka::client_properties_list
  file { "${kafka::confdir}/client.properties":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('kafka/properties.erb'),
  }

  if $::kafka::realm and $::kafka::realm != '' {
    file { "${::kafka::confdir}/jaas-client.conf":
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('kafka/jaas-client.conf.erb'),
    }
  } else {
    file { "${::kafka::confdir}/jaas-client.conf":
      ensure => 'absent',
    }
  }
}
