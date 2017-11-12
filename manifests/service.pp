# == Class kafka::service
#
# To ensure the kafka service is running.
#
class kafka::service {
  if $::kafka::service_name {
    service { $::kafka::service_name:
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
