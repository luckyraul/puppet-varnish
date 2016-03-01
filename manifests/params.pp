# == Class varnish::params
#
# This class is meant to be called from varnish
# It sets variables according to platform
#
class varnish::params {
    case $::osfamily {
      'Debian': {
          $packages = ['varnish','libvarnishapi1']
          $service_name = 'varnish'
          $service_ensure = 'running'
          $service_status = true

          $service_log_name = 'varnishlog'
          $service_log_ensure = 'running'
          $service_log_status = true

          $service_ncsa_name = 'varnishncsa'
          $service_ncsa_ensure = 'running'
          $service_ncsa_status = true


          case $::lsbdistcodename {
                'wheezy': {
                    $package_version = '3.0'
                }
                'jessie': {
                    $package_version = '4.1'
                }
                default: {
                    fail("Unsupported debian release: ${::lsbdistcodename}")
                }
          }
      }
      default: {
          fail("${::operatingsystem} not supported")
      }
    }
}
