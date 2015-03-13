# == Class: profiles::metrics::graphite_omnibus::relay
#
# This installs and configures carbon-relay for a graphite cluster
#
# === Authors
#
# Anthony Tonns <anthony@tonns.com>
#
class profiles::metrics::graphite_omnibus::relay {

    $cache_hosts = [
        "10.20.30.43:2004", # carbon-cache 1
        "10.20.30.44:2004", # carbon-cache 2
        "10.20.30.45:2004", # carbon-cache 3
    ]

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
        'relay' => {
            'LINE_RECEIVER_INTERFACE'       => '0.0.0.0',
            'LINE_RECEIVER_PORT'            => '2003',
            'PICKLE_RECEIVER_INTERFACE'     => '0.0.0.0',
            'PICKLE_RECEIVER_PORT'          => '2004',
            'ENABLE_UDP_LISTENER'           => 'True',
            'UDP_RECEIVER_INTERFACE'        => '0.0.0.0',
            'UDP_RECEIVER_PORT'             => '2003',
            'LOG_LISTENER_CONNECTIONS'      => 'True',
            'RELAY_METHOD'                  => 'consistent-hashing',
            'REPLICATION_FACTOR'            => '2',
            'DESTINATIONS'                  => $cache_hosts,
            'MAX_DATAPOINTS_PER_MESSAGE'    => '500',
            'MAX_QUEUE_SIZE'                => '10000',
            'QUEUE_LOW_WATERMARK_PCT'       => '0.8',
            'USE_FLOW_CONTROL'              => 'True',
        },
    }

    $relay_rules                    = {
        'default' => {
            'default'    => true,
            destinations => $cache_hosts,
        },
    }

    class { '::graphite_omnibus': 
        aggregation_service_ensure  => 'false',
        cache_service_ensure        => 'false',
        web_service_ensure          => 'false',
        carbon                      => $carbon,
        relay_rules                 => $relay_rules,
    }

}
