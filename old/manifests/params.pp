# == Class varnish::params
#
# This class is meant to be called from varnish
# It sets variables according to platform
#
class varnish::params {
    case $::osfamily {
      'Debian': {
          $packages = ['varnish']
          $package_ensure = 'latest'
          $service_name = 'varnish'
          $service_ensure = 'running'
          $service_status = true

          $service_log_name = 'varnishlog'
          $service_log_ensure = 'running'
          $service_log_status = true

          $service_ncsa_name = 'varnishncsa'
          $service_ncsa_ensure = 'running'
          $service_ncsa_status = true
          $manage_repos = true

          case $::lsbdistcodename {
                'stretch': {
                    $package_version = '6.4'
                }
                'buster': {
                    $package_version = '7.2'
                }
                'bullseye': {
                    $package_version = '7.2'
                }
                'bookworm': {
                    $package_version = '7.2'
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
