# Global Defaults
Exec {
    path      => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    logoutput => on_failure,
    timeout   => 0,
}

Service {
    hasrestart => true,
    hasstatus  => true,
}

Package {
    ensure => present,
}

File {
    ensure => present,
}

# Default Node
node default {
    class { 'apt': }
    class { 'git': }
    class { 'xenial': }

    ## LVM
    exec { 'pvcreate /dev/sdb -y':
        unless  => 'pvs /dev/sdb',
        require => Package['lvm2'],
        before  => Service['docker'],
    }

    exec { 'vgcreate lvm /dev/sdb':
        unless  => 'vgs lvm',
        require => Exec['pvcreate /dev/sdb -y'],
        before  => Service['docker'],
    }

    exec { 'lvcreate -n data lvm -l 95%VG':
        unless  => 'lvs /dev/lvm/data',
        require => Exec['vgcreate lvm /dev/sdb'],
        before  => Service['docker'],
    }

    exec { 'lvcreate -n metadata lvm -l 100%FREE':
        unless => 'lvs /dev/lvm/metadata',
        require => Exec['lvcreate -n data lvm -l 95%VG'],
        before  => Service['docker'],
    }

    exec { 'dd if=/dev/zero of=/dev/lvm/metadata bs=1M count=10':
        refreshonly => true,
        subscribe   => Exec['lvcreate -n metadata lvm -l 100%FREE'],
        before      => Service['docker'],
    }

    ## Docker
    class { 'docker':
        ensure      => '17.12.0~ce-0~ubuntu',
        docker_opts => '--init --storage-driver=devicemapper --storage-opt dm.datadev=/dev/lvm/data --storage-opt dm.metadatadev=/dev/lvm/metadata --storage-opt dm.blocksize=512K --storage-opt dm.fs=xfs',
    }

    class { 'docker::dockviz': }

    ## Group Memberships
    user { 'vagrant':
        groups  => ['docker'],
        require => Class['docker'],
    }
}