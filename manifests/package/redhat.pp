class varnish::package::redhat (
  $package_name = $varnish::package_name,
  $package_ensure = $varnish::package_ensure
) {
  package { 'varnish':
    ensure => $package_ensure,
    name   => $package_name,
  }
}
