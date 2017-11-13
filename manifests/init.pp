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
  $ssl = undef,
  $ssl_cacerts = $::kafka::params::cacerts,
  $ssl_cacerts_password = $::kafka::params::cacerts_password,
  $ssl_keystore = $::kafka::params::keystore,
  $ssl_keystore_keypassword = $::kafka::params::keystore_keypassword,
  $ssl_keystore_password = $::kafka::params::keystore_password,
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

  if $realm and $realm != '' {
    if $ssl {
      $protocol = 'SASL_SSL'
      $port = 9094
    } else {
      $protocol = 'SASL_PLAINTEXT'
      $port = 9093
    }
    $listeners = 'SASL_PLAINTEXT://0.0.0.0:9093,SASL_SSL://0.0.0.0:9094'
  } else {
    if $ssl {
      $protocol = 'SSL'
      $port = 9092
    } else {
      $protocol = 'PLAINTEXT'
      $port = 9091
    }
    $listeners = 'PLAINTEXT://0.0.0.0:9091,SSL://0.0.0.0:9092'
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
    'advertised.listeners' => "${protocol}://${::fqdn}:${port}",
    'listeners' => $listeners,
  }

  if $realm and $realm != '' {
    $sec_environment = {
      'KAFKA_OPTS' => "-Djava.security.auth.login.config=${::kafka::confdir}/jaas.conf",
    }
    $sec_properties = {
      'sasl.kerberos.service.name' => 'kafka',
      'security.protocol' => $protocol,
      'security.inter.broker.protocol' => $protocol,
    }
  } else {
    $sec_environment = undef
    $sec_properties = undef
  }

  if $ssl {
    $ssl_properties = {
      'security.protocol' => $protocol,
      'security.inter.broker.protocol' => $protocol,
      'ssl.keystore.location' => "${::kafka::homedir}/keystore.server",
      'ssl.keystore.password' => $ssl_keystore_password,
      'ssl.key.password' => $ssl_keystore_keypassword,
      'ssl.truststore.location' => $ssl_cacerts,
      'ssl.truststore.password' => $ssl_cacerts_password,
    }
  } else {
    $ssl_properties = undef
  }

  $_properties = merge($dyn_properties, $sec_properties, $ssl_properties, $properties)
  $_environment = merge($sec_environment, $environment)

  $client_properties_list = [
    'sasl.kerberos.service.name',
    'security.protocol',
    'ssl.truststore.location',
    'ssl.truststore.password',
  ]
}
