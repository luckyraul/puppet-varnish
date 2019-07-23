# == Class: varnish
class varnish (
    $packages                           = $varnish::params::packages,
    String $version                     = $varnish::params::package_version,
    $package_ensure                     = $varnish::params::package_ensure,
    $service_ensure                     = $varnish::params::service_ensure,
    $service_status                     = $varnish::params::service_status,
    $service_log_ensure                 = $varnish::params::service_log_ensure,
    $service_log_status                 = $varnish::params::service_log_status,
    $service_ncsa_ensure                = $varnish::params::service_ncsa_ensure,
    $service_ncsa_status                = $varnish::params::service_ncsa_status,
    $service_name                       = $varnish::params::service_name,

    String $admin_listen                = '127.0.0.1',
    Integer $admin_port                 = 6082,
    String $listen                      = '0.0.0.0',
    Integer $listen_port                = 6081,
    Stdlib::AbsolutePath $secret_file   = '/etc/varnish/secret',
    Stdlib::AbsolutePath $vcl_conf      = '/etc/varnish/default.vcl',
    String $storage_size                = '256m',
    Integer $ulimit                     = 131072,
    Enum['file','malloc'] $storage_type = 'malloc',

    $docker              = false,
) inherits varnish::params
{

    anchor { 'varnish::begin': }
    -> class { 'varnish::repo': }
    -> class { 'varnish::install': }
    -> class { 'varnish::config': }
    -> class { 'varnish::service': }
    -> anchor { 'varnish::end': }

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
