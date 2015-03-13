# == Class: graphite_omnibus::params
#
# graphite_omnibus parameters
#
# === Authors
#
# Anthony Tonns <anthony@tonns.com>
#

class graphite_omnibus::params {
    $package_ensure                 = 'installed'

    $relay_service_ensure           = 'true' # used for ensure and enable
    $cache_service_ensure           = 'true' # used for ensure and enable
    $aggregation_service_ensure     = 'true' # used for ensure and enable
    $web_service_ensure             = 'true' # used for ensure and enable

    # additional sysconfig parameters
    $relay_sysconfig                = [
    ]
    $cache_sysconfig                = [
    ]
    $aggregation_sysconfig          = [
    ]
    $web_sysconfig                  = [
    ]

    #
    # carbon configs
    #

    $aggregation_rules_conf         = 'graphite_omnibus/aggregation-rules.conf.erb'
    # aggregation_rules format:
    # { "ruleid" => "config line", }
    $aggregation_rules              = {
    }

    $blacklist_conf                 = 'graphite_omnibus/blacklist.conf.erb'
    # blacklist format:
    # [ "line1", ]
    $blacklist                      = [
    ]

    $carbon_conf                    = 'graphite_omnibus/carbon.conf.erb'
    # carbon format:
    # 'section1' => {
    #   'param1' => 'value1',
    #   'param2' => [ 'valueA', 'valueB', ],
    # },
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
            'MAX_UPDATES_PER_SECOND'        => '500',
            'MAX_CREATES_PER_MINUTE'        => '50',
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
        'relay' => {
            'LINE_RECEIVER_INTERFACE'       => '0.0.0.0',
            'LINE_RECEIVER_PORT'            => '2013',
            'PICKLE_RECEIVER_INTERFACE'     => '0.0.0.0',
            'PICKLE_RECEIVER_PORT'          => '2014',
            'LOG_LISTENER_CONNECTIONS'      => 'True',
            'RELAY_METHOD'                  => 'rules',
            'REPLICATION_FACTOR'            => '1',
            'DESTINATIONS'                  => '127.0.0.1:2004',
            'MAX_DATAPOINTS_PER_MESSAGE'    => '500',
            'MAX_QUEUE_SIZE'                => '10000',
            'QUEUE_LOW_WATERMARK_PCT'       => '0.8',
            'USE_FLOW_CONTROL'              => 'True',
        },
        'aggregator' => {
            'LINE_RECEIVER_INTERFACE'       => '0.0.0.0',
            'LINE_RECEIVER_PORT'            => '2023',
            'PICKLE_RECEIVER_INTERFACE'     => '0.0.0.0',
            'PICKLE_RECEIVER_PORT'          => '2024',
            'LOG_LISTENER_CONNECTIONS'      => 'True',
            'FORWARD_ALL'                   => 'False',
            'DESTINATIONS'                  => '127.0.0.1:2004',
            'REPLICATION_FACTOR'            => '1',
            'MAX_QUEUE_SIZE'                => '10000',
            'USE_FLOW_CONTROL'              => 'True',
            'MAX_DATAPOINTS_PER_MESSAGE'    => '500',
            'MAX_AGGREGATION_INTERVALS'     => '5',
        },
    }

    $relay_rules_conf               = 'graphite_omnibus/relay-rules.conf.erb'
    # relay_rules format:
    # 'section1' => {
    #   'param1' => 'value1',
    #   'param2' => [ 'valueA', 'valueB', ],
    # },
    $relay_rules                    = {
        'default' => {
            'default'    => true,
            destinations => [ '127.0.0.1:2004:a', '127.0.0.1:2104:b', ]
        },
    }

    $rewrite_rules_conf             = 'graphite_omnibus/rewrite-rules.conf.erb'
    # rewrite_rules format:
    # {
    #   pre => {
    #     'regex1' => 'replacement1',
    #     'regex2' => 'replacement2',
    #   },
    #   post => {
    #     'regex1' => 'replacement1',
    #     'regex2' => 'replacement2',
    #   },
    # },
    $rewrite_rules                  = {
    }

    $storage_schemas_conf           = 'graphite_omnibus/storage-schemas.conf.erb'
    # storage_schemas format:
    # [
    #   {
    #     name       => 'value1',
    #     pettern    => 'value2',
    #     retentions => 'value3',
    #   },
    # ]
    $storage_schemas                = [
        {
            name       => 'carbon',
            pattern    => '^carbon\.',
            retentions => '1m:90d'
        },
        {
            name       => 'default',
            pattern    => '.*',
            # the defaults graphite ships with are poor
            # retentions => '60s:1d'
            retentions => '1m:40d,5m:100d,15m:200d'
        },
    ]

    $storage_aggregation_conf       = 'graphite_omnibus/storage-aggregation.conf.erb'
    # storage_aggregation format:
    # 'section1' => {
    #   pettern => 'value1',
    #   factor  => 'value2',
    #   method  => 'value3',
    # },
    $storage_aggregation            = {
        '00_min' => {
            pattern => '\.min$',
            factor  => '0.1',
            method  => 'min'
        },
        '01_max' => {
            pattern => '\.max$',
            factor  => '0.1',
            method  => 'max'
        },
        '02_sum' => {
            pattern => '\.count$',
            factor  => '0.1',
            method  => 'sum'
        },
        '99_default_avg' => {
            pattern => '.*',
            factor  => '0.5',
            method  => 'average'
        }
    }

    $whitelist_conf                 = 'graphite_omnibus/whitelist.conf.erb'
    # whitelist format:
    # [ "line1", "line2", ]
    $whitelist                      = [
        '.*',
    ]

    #
    # graphite-web configs
    #
    $graphite_wsgi_conf             = 'graphite_omnibus/graphite.wsgi.erb'
    # graphite_wsgi format:
    # [
    #   '/path/to/python/library',
    # ]
    $graphite_wsgi = [
        '/opt/graphite-omnibus/graphite/lib',
        '/opt/graphite-omnibus/graphite/webapp',
    ]

    $dashboard_conf                 = 'puppet:///modules/graphite_omnibus/dashboard.conf'
    $graphtemplates_conf            = 'puppet:///modules/graphite_omnibus/graphTemplates.conf'

    $graphite_web_gunicorn_conf     = 'graphite_omnibus/graphite-web-gunicorn.conf.erb'
    # graphite_web_gunicorn format:
    # {
    #   "param1" => "value1",
    #   "param2" => "value2",
    # }
    $graphite_web_gunicorn          = {
        'chdir'     => "/opt/graphite/conf",
        'bind'      => "0.0.0.0:8888",
        'workers'   => "4",
        'daemon'    => "True",
        'user'      => "carbon",
        'group'     => "carbon",
        'pidfile'   => "/var/run/graphite-web.pid",
        'accesslog' => "/var/log/carbon/graphite-web.access.log",
        'errorlog'  => "/var/log/carbon/graphite-web.error.log",
    }

    $graphite_my_cnf                = 'graphite_omnibus/graphite-my.cnf.erb'
    # graphite_mysql format:
    # client => {
    #   pettern => 'value1',
    #   factor  => 'value2',
    #   method  => 'value3',
    # },
    $graphite_mysql                 = {
        client => {
            'default-character-set' => 'utf8',
            'database'              => 'graphite',
            'user'                  => 'graphite',
            'password'              => 'changeme',
        }
    }

    $local_settings_py              = 'graphite_omnibus/local_settings.py.erb'
    # local_settings format:
    # client => {
    #   pettern => 'value1',
    #   factor  => 'value2',
    #   method  => 'value3',
    # },
    $local_settings                 = {
        'CONF_DIR'              => '/opt/graphite/conf',
        'STORAGE_DIR'           => '/opt/graphite/storage',
        'DASHBOARD_CONF'        => '/opt/graphite/conf/dashboard.conf',
        'GRAPHTEMPLATES_CONF'   => '/opt/graphite/conf/graphTemplates.conf',
        'LOG_DIR'               => '/var/log/carbon',
        'DATABASES'             => {
            'default' => {
                'ENGINE' => 'django.db.backends.mysql',
                'HOST' => '127.0.0.1',
                'OPTIONS' => {
                   'read_default_file' => '/opt/graphite/conf/graphite-my.cnf',
                   'init_command' => 'SET storage_engine=INNODB',
                }
            }
        },
    }

}
