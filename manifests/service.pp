class varnish::service {
  assert_private()

  $default_opts = [
    '-F',
    "-a ${varnish::listen}:${varnish::listen_port}",
    "-T ${varnish::admin_listen}:${varnish::admin_port}",
    "-f ${varnish::varnish_vcl_conf}",
    "-S ${varnish::secret_file}",
    "-s malloc,${varnish::storage_size}",
    '-P %t/%N/varnishd.pid',
  ]

  systemd::dropin_file { 'varnish_service':
    unit     => "${varnish::service_name}.service",
    content  => epp('varnish/varnish.dropin.epp', { 'default_opts' => $default_opts }),
    filename => 'varnish_override.conf',
    require  => Package['varnish'],
  }

  if $varnish::service_manage {
    Systemd::Dropin_file['varnish_service'] ~> Service['varnish']

    service { 'varnish':
      ensure  => $varnish::service_ensure,
      name    => $varnish::service_name,
      enable  => $varnish::service_enable,
      require => Package['varnish'],
    }
    service { 'varnishnca':
      ensure  => $varnish::logservice_ensure,
      name    => $varnish::logservice_name,
      enable  => $varnish::logservice_enable,
      require => Package['varnish'],
    }
  }
}
