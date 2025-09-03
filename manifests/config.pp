class varnish::config {
  assert_private()
  $conf_dir = $varnish::conf_dir

  file { $conf_dir:
    ensure  => directory,
    require => Package['varnish'],
  }
  $uuid = fqdn_uuid($facts['networking']['fqdn'])

  exec { 'generate-secret-uuid':
    command => "/bin/echo ${uuid} > ${conf_dir}/secret",
    creates => "${conf_dir}/secret",
    path    => ['/bin', '/usr/bin'],
    require => Package['varnish'],
  }
}
