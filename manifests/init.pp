# Class: kafka
# ===========================
#
# Main class.
#
class kafka (
  $alternatives = '::default',
  $environment = undef,
  $zookeeper_chroot = '/kafka',
  $hostnames = undef,
  $zookeeper_hostnames = undef,
  $id = undef,
  $properties = undef,
  $package_name = $::kafka::params::package_name,
  $package_client_name = $::kafka::params::package_client_name,
  $service_name = $::kafka::params::service_name,
  $keytab = '/etc/security/keytab/kafka.service.keytab',
  $realm = '',
) inherits ::kafka::params {
  include ::stdlib

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
    $_zookeeper_hostnames = getvar('zookeeper::hostnames')
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
    # value generated properties.erb
    'zookeeper.connect' => '::undef',
    'zookeeper.connection.timeout.ms' => 6000,
  }

  if $realm and $realm != '' {
    $protocol = 'SASL_PLAINTEXT'
    $sec_environment = {
      'KAFKA_OPTS' => "-Djava.security.auth.login.config=${::kafka::confdir}/jaas.conf",
    }
    $sec_properties = {
      'advertised.listeners' => "SASL_PLAINTEXT://${::fqdn}:9093",
      'listeners' => 'SASL_PLAINTEXT://0.0.0.0:9093,SASL_SSL://0.0.0.0:9094',
      'sasl.kerberos.service.name' => 'kafka',
      'security.protocol' => $protocol,
      'security.inter.broker.protocol' => $protocol,
    }
  } else {
    $sec_environment = undef
    $sec_properties = undef
  }

  $_properties = merge($dyn_properties, $sec_properties, $properties)
  $_environment = merge($sec_environment, $environment)

  $client_properties_list = [
    'sasl.kerberos.service.name',
    'security.protocol',
  ]
}
