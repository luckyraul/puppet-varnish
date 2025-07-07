class varnish::params {
  $manage_repos = false
  $package_name = 'varnish'
  case $facts['os']['family'] {
    'Debian': {
      case $facts['os']['name'] {
        'Debian': {
          case $facts['os']['release']['major'] {
            '12': {
              $fresh = '77'
            }
            '11': {
              $fresh = '76'
            }
            default: {
              fail("Unsupported Debian release: ${fact('os.release.major')}")
            }
          }
        }
        'Ubuntu': {
          case $facts['os']['release']['major'] {
            '20.04', '22.04', '24.04': {
              $fresh = '77'
            }
            default: {
              fail("Unsupported Ubuntu release: ${fact('os.release.major')}")
            }
          }
        }
        default: {
          $fresh = '77'
        }
      }
    }
    default: {
      fail("Unsupported osfamily: ${facts['os']['family']}")
    }
  }
}
