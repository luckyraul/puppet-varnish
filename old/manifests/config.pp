# == Class varnish::config
#
# This class is called from varnish. It installs any necessary support files for
# varnish.
#
class varnish::config {
  include varnish::params
}
