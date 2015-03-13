# == Class: profiles::metrics::graphite_omnibus::cache
#
# This installs and configures carbon-cache for a graphite cluster
#
# === Authors
#
# Anthony Tonns <anthony@tonns.com>
#
class profiles::metrics::graphite_omnibus::cache {

    $carbon = {
        'DEFAULT' => {
            'CONF_DIR'                      => '/opt/graphite/conf/',
            'STORAGE_DIR'                   => '/opt/graphite/storage',
            'LOCAL_DATA_DIR'                => '/opt/graphite/storage/whisper/',
            'WHITELISTS_DIR'                => '/opt/graphite/storage/lists/',
            'LOG_DIR'                       => '/var/log/carbon',
            'PID_DIR'                       => '/var/run/',
            'LOCAL_DATA_DIR'                => '/opt/graphite/storage/whisper/',
            'USER'                          => 'carbon',
        },
        'cache' => {
            'ENABLE_LOGROTATION'            => 'True',
            'USER'                          => 'carbon',
            'MAX_CACHE_SIZE'                => 'inf',
            'MAX_UPDATES_PER_SECOND'        => '10000',
            'MAX_CREATES_PER_MINUTE'        => '500',
            'LINE_RECEIVER_INTERFACE'       => '0.0.0.0',
            'LINE_RECEIVER_PORT'            => '2003',
            'ENABLE_UDP_LISTENER'           => 'False',
            'UDP_RECEIVER_INTERFACE'        => '0.0.0.0',
            'UDP_RECEIVER_PORT'             => '2003',
            'PICKLE_RECEIVER_INTERFACE'     => '0.0.0.0',
            'PICKLE_RECEIVER_PORT'          => '2004',
            'LOG_LISTENER_CONNECTIONS'      => 'True',
            'USE_INSECURE_UNPICKLER'        => 'False',
            'CACHE_QUERY_INTERFACE'         => '0.0.0.0',
            'CACHE_QUERY_PORT'              => '7002',
            'USE_FLOW_CONTROL'              => 'True',
            'LOG_UPDATES'                   => 'False',
            'LOG_CACHE_HITS'                => 'False',
            'LOG_CACHE_QUEUE_SORTS'         => 'True',
            'CACHE_WRITE_STRATEGY'          => 'sorted',
            'WHISPER_AUTOFLUSH'             => 'False',
            'WHISPER_FALLOCATE_CREATE'      => 'True',
        },
    }

    # make this effectively empty because we use sqlite here, not mysql
    $graphite_mysql                 = {
        client => {
            'default-character-set' => 'utf8',
        }
    }

    # configure graphite-web with sqlite
    $local_settings = {
        'CONF_DIR'              => '/opt/graphite/conf',
        'STORAGE_DIR'           => '/opt/graphite/storage',
        'DASHBOARD_CONF'        => '/opt/graphite/conf/dashboard.conf',
        'GRAPHTEMPLATES_CONF'   => '/opt/graphite/conf/graphTemplates.conf',
        'LOG_DIR'               => '/var/log/carbon',
        'DATABASES'             => {
            'default' => {
                'NAME'      => '/opt/graphite/storage/graphite.db',
                'ENGINE'    => 'django.db.backends.sqlite3',
                'USER'      => '',
                'PASSWORD'  => '',
                'HOST'      => '',
                'PORT'      => '',
            }
        },
    }

    # create the sqlite database the django way
    exec { "graphite-sqlite3-db":
        environment => 'PYTHONPATH=/opt/graphite-omnibus/graphite/lib',
        cwd         => '/opt/graphite/storage',
        command     => '/opt/graphite-omnibus/bin/python /opt/graphite-omnibus/graphite/lib/graphite/manage.py syncdb --settings=graphite.settings --noinput',
        path        => '/usr/bin:/usr/sbin:/bin',
        unless      => 'test -f /opt/graphite/storage/graphite.db',
        require     => [
            Package['graphite-omnibus'],
            File['/opt/graphite/storage'],
        ],
        notify      => [
            Service['graphite-web-gunicorn'],
        ],
    }

    class { '::graphite_omnibus': 
        aggregation_service_ensure  => 'false',
        relay_service_ensure        => 'false',
        carbon                      => $carbon,
        graphite_mysql              => $graphite_mysql,
        local_settings              => $local_settings,
    }

}
