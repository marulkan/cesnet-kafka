# == Class kafka::config
#
# Configure kafka
#
class kafka::config {
  file { "${kafka::confdir}/server.properties":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('kafka/server.properties.erb'),
  }
}
