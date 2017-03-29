# == Class: varnish
class varnish (
    $packages            = $varnish::params::packages,
    $version             = $varnish::params::package_version,
    $package_ensure      = $varnish::params::package_ensure,
    $service_ensure      = $varnish::params::service_ensure,
    $service_status      = $varnish::params::service_status,
    $service_log_ensure  = $varnish::params::service_log_ensure,
    $service_log_status  = $varnish::params::service_log_status,
    $service_ncsa_ensure = $varnish::params::service_ncsa_ensure,
    $service_ncsa_status = $varnish::params::service_ncsa_status,


    $docker              = false,
) inherits varnish::params
{
    anchor { 'varnish::begin': } ->
    class { 'varnish::repo': } ->
    class { 'varnish::install': } ->
    class { 'varnish::config': } ->
    class { 'varnish::service': } ->
    anchor { 'varnish::end': }

    if $docker {
      file {'/start.sh':
          owner   => root,
          group   => root,
          mode    => '0755',
          content => template('varnish/docker/start.sh.erb'),
      }
    }

    Anchor['varnish::begin']  ~> Class['varnish::service']
    Class['varnish::install'] ~> Class['varnish::service']
    Class['varnish::config']  ~> Class['varnish::service']
}
