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
          $version_code  = '50'
          $key_id = '1487779B0E6C440214F07945632B6ED0FF6A1C76'
      }
      '5.1': {
          $version_code  = '51'
          $key_id = '54DC32329C37703D8B2819E6414C46826B880524'
      }
      '5.2': {
          $version_code  = '52'
          $key_id = '91CFD5635A1A5FAC0662BEDD2E9BA3FE86BE909D'
      }
      '6.0': {
          $version_code  = '60'
          $key_id = '7C5B46721AF00FD57E68E6E8D2605BF74E8B9DBA'
      }
      '6.1': {
          $version_code  = '61'
          $key_id = '4A066C99B76A0F55A40E3E1E387EF1F5742D76CC'
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
