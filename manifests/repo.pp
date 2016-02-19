# == Class varnish::repo
#
# This class is called from varnish. It ensures the varnish apt repo is
# installed. It will fail if called on it's own.
#
class varnish::repo {
    include apt

    if ! defined(Package['apt-transport-https']) {
        package { 'apt-transport-https':
            ensure => latest,
        }
    }

    case $varnish::package_version {
      '3.0': {
          if $::lsbdistcodename == 'jessie' {
              apt::pin { 'varnish':
                  ensure   => 'present',
                  packages => [$varnish::packages],
                  priority => 500,
                  version  => '3.*'
              }
          }
      }
      '4.0','4.1': {

      }
      default: {
          fail("Unsupported release: ${varnish::package_version}")
      }
    }

    apt::source { 'varnish-cache':
        location    => $::varnish::params::apt_key,
        release     => $::lsbdistcodename,
        repos       => "varnish-${varnish::package_version}",
        key         => $::varnish::params::apt_key,
        key_source  => $::varnish::params::apt_key_source,
        include_src => false,
    }

    Exec['apt_update'] -> Package[$varnish::packages]
}
