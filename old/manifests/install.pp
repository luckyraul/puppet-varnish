# == Class varnish::install
#
# This class is called from varnish. It installs necessary packages. It will
# fail if called on it's own.
#
class varnish::install {
  $packages = $varnish::packages
  $ensure   = $varnish::package_ensure
  $admin_listen = $varnish::admin_listen
  $admin_port = $varnish::admin_port
  $listen = $varnish::listen
  $listen_port = $varnish::listen_port
  $secret_file = $varnish::secret_file
  $vcl_conf = $varnish::vcl_conf
  $storage_type = $varnish::storage_type
  $storage_size = $varnish::storage_size
  $ulimit = $varnish::ulimit
  $manage_repos = $varnish::manage_repos

  package { $packages :
    ensure => $ensure,
    tag    => 'varnish-install',
  }

  if (!$manage_repos) {
    Package[$packages] -> package { 'varnish-modules':
      ensure => installed,
    }
  }

  systemd::dropin_file { 'override.conf':
    unit    => 'varnish.service',
    content => template('varnish/systemd.service.erb'),
  } -> Service[$varnish::service_name]
}
