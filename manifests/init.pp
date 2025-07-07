class varnish (
  String $package_ensure = installed,
  String $package_name = $varnish::params::package_name,
  Boolean $manage_repos = $varnish::params::manage_repos,
  Varnish::Package_source $package_source = 'lts',
  Stdlib::Ensure::Service $service_ensure = 'running',
  Boolean $service_enable = true,
  String $service_name = 'varnish',
  Boolean $service_manage = true,
  String $listen = '', # lint:ignore:params_empty_string_assignment
  Integer $listen_port = 6081,
  String $admin_listen = '127.0.0.1',
  Integer $admin_port = 6082,
  Stdlib::Absolutepath $varnish_vcl_conf = '/etc/varnish/default.vcl',
  Stdlib::AbsolutePath $secret_file = '/etc/varnish/secret',
  String $storage_size = '256m',
  String $daemon_opts = '-j unix,user=vcache',
  Hash $instances = {},
) inherits varnish::params {
  contain 'varnish::package'
  contain 'varnish::config'
  contain 'varnish::service'

  create_resources( 'varnish::resource::instance', $instances, {})
}
