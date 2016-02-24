# == Class varnish::repo
#
# This class is called from varnish. It ensures the varnish apt repo is
# installed. It will fail if called on it's own.
#
class varnish::repo (
    $location = 'https://repo.varnish-cache.org/debian/',
    $key          = {
        'id'     => 'E98C6BBBA1CBC5C3EB2DF21C60E7C096C4DEFFEB',
        'source' => 'https://repo.varnish-cache.org/GPG-key.txt',
    }
    ){
    include apt

    if ! defined(Package['apt-transport-https']) {
        package { 'apt-transport-https':
            ensure => latest,
        }
    }

    create_resources(::apt::key, { 'varnish_cache' => {
        id => $key['id'], source => $key['source'],
    }})

    case $varnish::version {
      '3.0': {
          if $::lsbdistcodename == 'jessie' {
              apt::pin { 'varnish':
                  ensure   => 'present',
                  packages => [$varnish::packages],
                  priority => 550,
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
        location => $location,
        release  => $::lsbdistcodename,
        repos    => "varnish-${varnish::version}",
        include  => {
            'src' => false
        }
    }

    Exec['apt_update'] -> Package[$varnish::packages]
}
