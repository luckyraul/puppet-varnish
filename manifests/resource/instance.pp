define varnish::resource::instance (
  Enum['present', 'absent'] $ensure = 'present'
) {
  if !defined(Class['varnish']) {
    fail('You must include the varnish base class before using any defined resources')
  }
}
