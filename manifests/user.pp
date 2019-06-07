# == Class kafka::user
#
class kafka::user {
  group { 'kafka':
    ensure => present,
    system => true,
  }
  case "${::osfamily}-${::operatingsystem}" {
    /RedHat-Fedora/: {
      user { 'kafka':
        ensure     => present,
        system     => true,
        comment    => 'Apache Kafka',
        gid        => 'hive',
        home       => '/var/lib/kafka',
        managehome => true,
        password   => '!!',
        shell      => '/sbin/nologin',
      }
    }
    /Debian|RedHat/: {
      user { 'kafka':
        ensure     => present,
        system     => true,
        comment    => 'Kafka User',
        gid        => 'kafka',
        home       => '/var/lib/kafka',
        managehome => true,
        password   => '!!',
        shell      => '/bin/false',
      }
    }
    default: {
      notice("${::osfamily} not supported")
    }
  }
  Group['kafka'] -> User['kafka']
