# == Class varnish::repo
#
# This class is called from varnish. It ensures the varnish apt repo is
# installed. It will fail if called on it's own.
#
class varnish::repo (
    $version  = $varnish::version,
    ) {
    include apt
    validate_string($version)
    validate_slength($version, 3, 3)

    ensure_packages(['apt-transport-https'], {'ensure' => latest})

    case $version {
      '3.0': {
          $version_code  = '30'
          $key_id = '246BE381150865E2DC8C6B01FC1318ACEE2C594C'
          if $::lsbdistcodename == 'jessie' {
              apt::pin { 'varnish':
                  ensure   => 'present',
                  packages => [$varnish::packages],
                  priority => 550,
                  version  => '3.*'
              }
          }
      }
      '4.0': {
          $version_code  = '40'
          $key_id = 'B7B16293AE0CC24216E9A83DD4E49AD8DE3FFEA4'
      }
      '4.1': {
          $version_code  = '41'
          $key_id = '9C96F9CA0DC3F4EA78FF332834BF6E8ECBF5C49E'
      }
      '5.0': {
          $version_code  = '5'
          $key_id = '3E925951E2C07969121BDAB481F8CA2EC23F55C5'
      }
      '5.1': {
          $version_code  = '51'
          $key_id = 'D9BC9B0F44870207A88FC3B33746967BC02AF8C2'
      }
      default: {
          fail("Unsupported release: ${varnish::version}")
      }
    }

    create_resources(::apt::key, { 'varnish::repo' => {
      id => $key_id, source => "https://packagecloud.io/varnishcache/varnish${version_code}/gpgkey",
    }})

    ::apt::source { "varnish_${version}":
      location => "https://packagecloud.io/varnishcache/varnish${version_code}/debian/",
      release  => $::lsbdistcodename,
      repos    => 'main',
      include  => {
        'src' => false
      },
      require  => Apt::Key['varnish::repo'],
    }

    Exec['apt_update'] -> Package[$varnish::packages]
}
