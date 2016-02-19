# == Class varnish::service
#
# This class is meant to be called from varnish It ensure the service is stopped
# since we manage varnish instances from the varnish::instance resource.
#
class varnish::service {
  include varnish::params

  service { $varnish::params::service_name:
    ensure     => $varnish::service_ensure,
    enable     => $varnish::service_status,
    hasstatus  => true,
    hasrestart => true,
  }

  service { $varnish::params::service_log_name:
    #ensure     => $varnish::service_log_ensure,
    #enable     => $varnish::service_log_status,
    hasstatus  => true,
    hasrestart => true,
  }

  service { $varnish::params::service_ncsa_name:
    #ensure     => $varnish::service_ncsa_ensure,
    #enable     => $varnish::service_ncsa_status,
    hasstatus  => true,
    hasrestart => true,
  }
}
