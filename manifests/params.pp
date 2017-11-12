# == Class kafka::params
#
# This class is meant to be called from kafka.
# It sets variables according to platform.
#
class kafka::params {
  case $::osfamily {
    default: {
      $confdir = '/etc/kafka/conf'
      $package_name = 'kafka-server'
      $package_client_name = 'kafka'
      $service_name = 'kafka-server'
    }
  }
}
