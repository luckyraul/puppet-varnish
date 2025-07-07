class varnish::service {
  assert_private()

  $default_opts = [
    '-F',
    "-a ${varnish::listen}:${varnish::listen_port}",
    "-T ${varnish::admin_listen}:${varnish::admin_port}",
    "-f ${varnish::varnish_vcl_conf}",
    "-S ${varnish::secret_file}",
    "-s malloc,${varnish::storage_size}",
  ]

  systemd::dropin_file { 'varnish_service':
    unit     => 'varnish.service',
    content  => epp('varnish/varnish.dropin.epp', { 'default_opts' => $default_opts }),
    filename => 'varnish_override.conf',
  }

  if $varnish::service_manage {
    Systemd::Dropin_file['varnish_service'] ~> Service[$varnish::service_name]

    service { $varnish::service_name:
      ensure  => $varnish::service_ensure,
      enable  => $varnish::service_enable,
      require => Package['varnish'],
    }
  }
}
