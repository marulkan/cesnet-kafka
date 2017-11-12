# == Class kafka::install
#
# This class is called from kafka for install.
#
class kafka::install {
  include ::stdlib

  if ($::kafka::package_name) {
    ensure_packages($::kafka::package_name)

    ::hadoop_lib::postinstall{'kafka':
      alternatives => $::kafka::alternatives,
    }
    Package[$::kafka::package_name] -> ::Hadoop_lib::Postinstall['kafka']
  }
}
