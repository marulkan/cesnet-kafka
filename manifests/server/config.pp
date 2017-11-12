# == Class kafka::server::config
#
# Configure Kafka broker
#
class kafka::server::config {
  include ::stdlib

  file { "${kafka::confdir}/server.properties":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('kafka/server.properties.erb'),
  }
}
