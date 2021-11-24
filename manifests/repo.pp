# == Class varnish::repo
#
# This class is called from varnish. It ensures the varnish apt repo is
# installed. It will fail if called on it's own.
#
class varnish::repo (
    String $version  = $varnish::version,
    ) {
    include apt

    case $version {
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
      '6.2': {
          $version_code  = '62'
          $key_id = 'B54813B54CA95257D3590B3F1B0096460868C7A9'
      }
      '6.3': {
          $version_code  = '63'
          $key_id = '920A8A7AA7120A8604BCCD294A42CD6EB810E55D'
      }
      '6.4': {
          $version_code  = '64'
          $key_id = 'A9897320C397E3A60C03E8BF821AD320F71BFF3D'
      }
      '7.0': {
          $version_code  = '70'
          $key_id = 'A4FED748BC3C7FC82C34F108985A1C79B02B8211'
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
