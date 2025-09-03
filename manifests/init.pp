class varnish (
  String $package_ensure = installed,
  String $package_name = $varnish::params::package_name,
  Boolean $manage_repos = $varnish::params::manage_repos,
  Varnish::Package_source $package_source = 'lts',
  Boolean $service_manage = true,
  Boolean $service_enable = true,
  Stdlib::Ensure::Service $service_ensure = 'running',
  String $service_name = 'varnish',
  Boolean $logservice_enable = false,
  String $logservice_name = 'varnishncsa',
  Stdlib::Ensure::Service $logservice_ensure = 'stopped',
  String $listen = '', # lint:ignore:params_empty_string_assignment
  Integer $listen_port = 6081,
  String $admin_listen = '127.0.0.1',
  Integer $admin_port = 6082,
  Stdlib::Absolutepath $varnish_vcl_conf = '/etc/varnish/default.vcl',
  Stdlib::AbsolutePath $secret_file = '/etc/varnish/secret',
  String $storage_size = '256m',
  String $conf_dir = $varnish::params::conf_dir,
  String $daemon_opts = '-j unix,user=vcache',
  Hash $instances = {},
) inherits varnish::params {
  contain 'varnish::package'
  contain 'varnish::config'
  contain 'varnish::service'

  create_resources( 'varnish::resource::instance', $instances, {})
}
