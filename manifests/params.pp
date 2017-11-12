# == Class kafka::params
#
# This class is meant to be called from kafka.
# It sets variables according to platform.
#
class kafka::params {
  $confdir = '/etc/kafka/conf'
  $package_name = 'kafka-server'
  $service_name = 'kafka-server'
}
