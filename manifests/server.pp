# Class: kafka::server
#
# Kafka broker
#
class kafka::server {
  include ::kafka::user

  class { '::kafka::server::install': }
  -> class { '::kafka::server::config': }
  ~> class { '::kafka::server::service': }
  -> Class['::kafka::server']
}
