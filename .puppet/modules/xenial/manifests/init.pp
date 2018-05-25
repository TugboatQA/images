class xenial {

    apt::source { 'xenial-main':
        location    => 'http://archive.ubuntu.com/ubuntu',
        release     => 'xenial',
        repos       => 'main restricted',
        include_src => false,
        require     => File['/etc/apt/preferences.d/xenial'],
        before      => Package['xfsprogs'],
    }

    apt::source { 'xenial-security':
        location    => 'http://security.ubuntu.com/ubuntu',
        release     => 'xenial',
        repos       => 'main restricted',
        include_src => false,
        require     => File['/etc/apt/preferences.d/xenial'],
        before      => Package['xfsprogs'],
    }

    file { '/etc/apt/preferences.d/xenial':
        content => template('xenial/etc/apt/preferences.d/xenial.erb'),
    }
}