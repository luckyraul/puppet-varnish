class varnish::package (
  $package_name = $varnish::package_name,
  $package_ensure = $varnish::package_ensure
) {
  assert_private()
  case $facts['os']['family'] {
    'redhat': {
      contain varnish::package::redhat
    }
    'debian': {
      contain varnish::package::debian
    }
    default: {
      package { $package_name:
        ensure => $package_ensure,
      }
    }
  }
}
