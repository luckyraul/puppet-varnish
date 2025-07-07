class varnish::package::debian (
  $package_name = $varnish::package_name,
  $package_ensure = $varnish::package_ensure,
  $manage_repos = $varnish::manage_repos,
  $package_source = $varnish::package_source,
  $fresh = $varnish::params::fresh,
) {
  package { 'varnish':
    ensure => $package_ensure,
    name   => $package_name,
  }

  if $manage_repos {
    include 'apt'
    Exec['apt_update'] -> Package['varnish']
    stdlib::ensure_packages(['apt-transport-https'])
    $os_lower = downcase($facts['os']['name'])
    apt::pin { 'varnish-repo':
      packages   => 'varnish varnish-*',
      originator => 'packagecloud.io/varnishcache/*',
      priority   => 1000,
    }
    case $package_source {
      'lts': {
        apt::keyring { 'varnish-lts.asc':
          source  => 'https://packagecloud.io/varnishcache/varnish60lts/gpgkey',
          require => Apt::Pin['varnish-repo'],
        } -> apt::source { 'varnish':
          enabled       => true,
          source_format => 'sources',
          location      => ["https://packagecloud.io/varnishcache/varnish60lts/${os_lower}/"],
          repos         => ['main'],
          architecture  => [$facts['os']['architecture']],
          require       => Package['apt-transport-https'],
          keyring       => '/etc/apt/keyrings/varnish-lts.asc',
        }
      }
      'fresh': {
        apt::keyring { 'varnish-fresh.asc':
          source  => "https://packagecloud.io/varnishcache/varnish${fresh}/gpgkey",
          require => Apt::Pin['varnish-repo'],
        } -> apt::source { 'varnish':
          enabled       => true,
          source_format => 'sources',
          location      => ["https://packagecloud.io/varnishcache/varnish${fresh}/${os_lower}/"],
          repos         => ['main'],
          architecture  => [$facts['os']['architecture']],
          require       => Package['apt-transport-https'],
          keyring       => '/etc/apt/keyrings/varnish-fresh.asc',
        }
      }
      default: {
        fail("\$package_source must be 'lts' or 'fresh'. It was set to '${package_source}'")
      }
    }
  }
}
