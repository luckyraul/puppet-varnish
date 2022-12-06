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
      '6.6': {
          $version_code  = '66'
          $key_id = 'A0378A38E4EACA3660789E570BAC19E3F6C90CD5'
      }
      '7.2': {
          $version_code  = '72'
          $key_id = 'CEF46AAF4564F3974FDBED9710106C467B0C948E'
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
        'src' => false,
      },
      require  => Apt::Key['varnish::repo'],
    }

    Exec['apt_update'] -> Package[$varnish::packages]
}
