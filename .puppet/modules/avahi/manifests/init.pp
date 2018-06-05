class avahi (
    $domain_name = 'local',
    $allow_interfaces = undef,
    $use_ipv6 = 'yes',
) {

    if !defined(Package['avahi-daemon']) {
        package { 'avahi-daemon': }
    }

    if !defined(Package['avahi-utils']) {
        package { 'avahi-utils': }
    }

    file { '/etc/avahi/avahi-daemon.conf':
        content => template('avahi/etc/avahi/avahi-daemon.conf.erb'),
        require => Package['avahi-daemon'],
        notify  => Service['avahi-daemon'],
    }

    service { 'avahi-daemon':
        ensure  => running,
        enable  => true,
        require => Package['avahi-daemon'],
    }

}
