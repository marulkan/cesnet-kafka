# Class: kafka::client
#
# Kafka client
#
class kafka::client {
  class { '::kafka::client::install': }
  -> class { '::kafka::client::config': }
  ~> class { '::kafka::client::service': }
  -> Class['::kafka::client']
}
