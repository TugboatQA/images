class docker (
    $docker_opts = undef,
    $ensure = 'present',
    $repo = 'stable',
) {

    apt::key { 'docker':
        key        => '0EBFCD88',
        key_source => 'https://download.docker.com/linux/ubuntu/gpg',
    }

    apt::source { 'docker':
        architecture => 'amd64',
        location     => 'https://download.docker.com/linux/ubuntu',
        release      => 'trusty',
        repos        => $repo,
        include_src  => false,
        require      => Apt::Key['docker'],
        before       => Package['docker-ce'],
    }

    if !defined(Package['lvm2']) {
        package { 'lvm2': }
    }

    if !defined(Package['xfsprogs']) {
        package { 'xfsprogs': }
    }

    package { 'docker-ce':
        ensure  => $ensure,
        require => Package['lvm2', 'xfsprogs'],
    }

    file { '/etc/default/docker':
        content => template('docker/etc/default/docker.erb'),
        require => Package['docker-ce'],
        notify  => Service['docker']
    }

    file { '/etc/apt/preferences.d/docker-ce':
        content => template('docker/etc/apt/preferences.d/docker-ce.erb'),
    }

    service { 'docker':
        ensure  => running,
        enable  => true,
        require => Package['docker-ce'],
    }
}
