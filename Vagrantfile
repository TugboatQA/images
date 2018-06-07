# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'fileutils'
require 'yaml'

## Read VM settings from "Vagrant.yml". These settings can be overridden by
## values in an optional "Vagrant.local.yml" file, which is ignored by git.

dir = File.dirname(File.expand_path(__FILE__))
settings = YAML::load_file("#{dir}/Vagrant.yml")
if File.exists?("#{dir}/Vagrant.local.yml")
    local = YAML::load_file("#{dir}/Vagrant.local.yml")
    settings["vb"].merge!(local["vb"])
end

BOX = "ubuntu/trusty64"

################################################################################

# Require vagrant 1.8.1 or higher
Vagrant.require_version ">= 1.8.1"

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.hostname="tugboat-images.local"
    config.vm.box = BOX

    # Network settings
    config.vm.network settings["vb"]["network"], bridge: settings["vb"]["bridge"], type: "dhcp"

    # VM hardware settings
    config.vm.provider "virtualbox" do |vb|
        if settings["vb"]["lvmdir"] then
            lvmdir = settings["vb"]["lvmdir"]
        else
            lvmdir = File.join(Dir.home(), '.tugboat')
        end

        unless File.directory?(lvmdir)
            FileUtils.mkdir_p(lvmdir)
        end

        lvm = File.join(lvmdir, 'images-lvm.vmdk')
        unless File.exists?(lvm)
            vb.customize ["createhd", "--filename", lvm, "--size", settings["vb"]["lvmsize"] * 1024]
        end

        vb.customize ["storageattach", :id, "--storagectl", "SATAController", "--port", 1, "--device", 0, "--type", "hdd", "--medium", lvm]

        vb.customize ["modifyvm", :id, "--memory", settings["vb"]["memory"]]
        vb.customize ["modifyvm", :id, "--cpus", settings["vb"]["cpus"]]
        vb.customize ["modifyvm", :id, "--natnet1", settings["vb"]["subnet"]]
    end

    # Disable IPv6
    config.vm.provision "shell", inline: "sysctl -w net.ipv6.conf.all.disable_ipv6=1", run: "always"
    config.vm.provision "shell", inline: "sysctl -w net.ipv6.conf.default.disable_ipv6=1", run: "always"

    # Run aptitude update before other provisioning takes place
    config.vm.provision "shell", inline: "if [[ ! -f /var/cache/apt/vagrant || ! -f /var/cache/apt/pkgcache.bin || $(stat -L --format %Y /var/cache/apt/pkgcache.bin) -le $(( $(date +%s) - 86400 )) ]]; then aptitude update; touch /var/cache/apt/vagrant; fi"

    # Local Puppet provisioner
    config.vm.provision "puppet" do |puppet|
        puppet.module_path = ".puppet/modules"
        puppet.manifests_path = ".puppet"
        puppet.manifest_file = "vagrant.pp"
        puppet.options = "--verbose --show_diff --hiera_config /vagrant/.puppet/hiera.yaml"
    end

    # Add defined SSH public key to vagrant user's authorized_keys
    if settings["vb"]["sshkey"]
        config.vm.provision "shell", inline: "echo \"#{settings['vb']['sshkey']}\" >> ~vagrant/.ssh/authorized_keys"
    end

end
