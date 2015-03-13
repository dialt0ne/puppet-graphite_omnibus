# == Class: graphite_omnibus::install
#
# Installs graphite_omnibus package and create base directories
#
# === Parameters
#
# [*package_ensure*]
#   Status of the graphite_omnibus package.
#
# === Authors
#
# Anthony Tonns <antony@tonns.com>
#
class graphite_omnibus::install (
    $package_ensure  = $::graphite_omnibus::params::package_ensure,
) inherits graphite_omnibus::params {

    # install graphite
    package { 'graphite-omnibus':
        ensure  =>  $package_ensure,
    }
    # fonts required for rendering graphs
    package { 'bitmap-fonts-compat':
        ensure  =>  $package_ensure,
    }

    # default directory permissions
    File {
        owner   =>  'root',
        group   =>  'root',
        mode    =>  0755,
    }

    # setup graphite directories
    $graphite_directories = [
        '/opt/graphite',
        '/opt/graphite/conf',
        '/opt/graphite/webapp',
        '/opt/graphite/webapp/graphite',
    ]
    file { $graphite_directories:
        ensure  => 'directory',
        require =>  Package['graphite-omnibus'],
    }

    # setup other carbon owned directories
    $graphite_carbon_directories = [
        '/var/log/carbon',
        '/opt/graphite/storage',
        '/opt/graphite/storage/.python-eggs',
    ]
    file { $graphite_carbon_directories:
        ensure  => 'directory',
        owner   =>  'carbon',
        group   =>  'carbon',
        recurse =>  'true',
        require =>  File['/opt/graphite'],
    }

}
