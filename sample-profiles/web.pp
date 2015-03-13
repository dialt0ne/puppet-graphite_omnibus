# == Class: profiles::metrics::graphite_omnibus::web
#
# This installs and configures graphite-web for a graphite cluster
#
# === Authors
#
# Anthony Tonns <anthony@tonns.com>
#
class profiles::metrics::graphite_omnibus::web {

    include ::stdlib

    $memcache_hosts = [
        "10.20.30.46:11211", # graphite-web 1
        "10.20.30.47:11211", # graphite-web 2
    ]

    $cache_hosts = [
        "10.20.30.43:8888", # carbon-cache 1
        "10.20.30.44:8888", # carbon-cache 2
        "10.20.30.45:8888", # carbon-cache 3
    ]

    $mysql_primary = "graphitedb.example.com"

    $local_settings                 = {
        'CONF_DIR'              => '/opt/graphite/conf',
        'STORAGE_DIR'           => '/opt/graphite/storage',
        'DASHBOARD_CONF'        => '/opt/graphite/conf/dashboard.conf',
        'GRAPHTEMPLATES_CONF'   => '/opt/graphite/conf/graphTemplates.conf',
        'LOG_DIR'               => '/var/log/carbon',
        'DATABASES'             => {
            'default' => {
                'ENGINE'    => 'django.db.backends.mysql',
                'HOST'      => $mysql_primary,
                'OPTIONS'   => {
                   'read_default_file'  => '/opt/graphite/conf/graphite-my.cnf',
                   'init_command'       => 'SET storage_engine=INNODB',
                }
            }
        },
        'MEMCACHE_HOSTS'                => $memcache_hosts,
        'DEFAULT_CACHE_DURATION'        => [ 'nonstring', 60 ],
        'CLUSTER_SERVERS'               => $cache_hosts,
        'REMOTE_STORE_FETCH_TIMEOUT'    => [ 'nonstring', 6 ],
        'REMOTE_STORE_FIND_TIMEOUT'     => [ 'nonstring', 2.5 ],
        'REMOTE_STORE_RETRY_DELAY'      => [ 'nonstring', 30 ],
        'REMOTE_FIND_CACHE_DURATION'    => [ 'nonstring', 300 ],
        'REMOTE_PREFETCH_DATA'          => [ 'nonstring', False ],
        'REMOTE_RENDERING'              => [ 'nonstring', False ],
    }

    $graphite_mysql = {
        client => {
            'default-character-set' => 'utf8',
            'database'              => 'graphite',
            'user'                  => 'graphite',
            'password'              => 'XXXXXXXXXXXX',
        }
    }

    include "::logrotate"
    include "::nginx"

    # wipe out default configs
    file { '/etc/nginx/conf.d/default.conf':
        ensure  => 'absent',
    }
    file { '/etc/nginx/conf.d/example_ssl.conf':
        ensure  => 'absent',
    }
    # add our custom config
    file { '/etc/nginx/conf.d/graphite_omnibus.conf':
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        source  => "puppet:///modules/profiles/graphite_omnibus/nginx/graphite_omnibus.conf",
        require => Package['nginx'],
        notify  => Service['nginx'],
    }

    class { "::memcached":
        size => "128",
    }

    class { '::graphite_omnibus': 
        aggregation_service_ensure  => 'false',
        cache_service_ensure        => 'false',
        relay_service_ensure        => 'false',
        graphite_mysql              => $graphite_mysql,
        local_settings              => $local_settings,
    }

}
