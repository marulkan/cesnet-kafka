# Class: kafka
# ===========================
#
# Main class.
#
class kafka (
  $alternatives = '::default',
  $zookeeper_chroot = '/kafka',
  $hostnames = undef,
  $zookeeper_hostnames = undef,
  $id = undef,
  $properties = undef,
  $package_name = $::kafka::params::package_name,
  $package_client_name = $::kafka::params::package_client_name,
  $service_name = $::kafka::params::service_name,
) inherits ::kafka::params {
  include ::stdlib
  include ::zookeeper

  if $id {
    $_id = $id
  } else {
    if $hostnames {
      # helper function from zookeeper puppet module
      $_id = array_search($hostnames, $::fqdn)
    } else {
      $_id = undef
    }
  }
  notice("broker.id: ${_id}")

  if $zookeeper_hostnames {
    $_zookeeper_hostnames = $zookeeper_hostnames
  } else {
    $_zookeeper_hostnames = $::zookeeper::hostnames
  }

  # 0 is OK, but counting from 1 here
  if !$_id or $_id == 0 {
    notice("Missing id and broker server ${::fqdn} not in kafka::hostnames list.")
  }

  $dyn_properties = {
    'broker.id' => $_id,
    'num.network.threads' => 3,
    'num.io.threads' => 8,
    'socket.send.buffer.bytes' => 102400,
    'socket.receive.buffer.bytes' => 102400,
    'socket.request.max.bytes' => 104857600,
    'log.dirs' => '/tmp/kafka-logs',
    'num.partitions' => 1,
    'num.recovery.threads.per.data.dir' => 1,
    'log.retention.hours' => 168,
    #'log.retention.bytes' => 1073741824,
    'log.segment.bytes' => 1073741824,
    'log.retention.check.interval.ms' => 300000,
    # in server.properties.erb
    #'zookeeper.connect' => '',
    'zookeeper.connection.timeout.ms' => 6000,
  }

  $_properties = merge($dyn_properties, $properties)
}
