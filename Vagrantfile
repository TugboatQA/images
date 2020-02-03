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

################################################################################

$packages = <<SCRIPT
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -yq \
    avahi-daemon \
    curl \
    git \
    jq \
    software-properties-common
SCRIPT

$docker = <<SCRIPT
#/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Docker repository
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt-get update

# Install docker
apt-get install -yq docker-ce

# Add the vagrant user to the docker group
usermod -a -G docker vagrant
SCRIPT

################################################################################

# Require vagrant 1.8.1 or higher
Vagrant.require_version ">= 1.8.1"

Vagrant.configure(2) do |config|
    config.vm.hostname="tugboat-images.local"
    config.vm.box = settings["vb"]["box"]

    # Network settings
    config.vm.network settings["vb"]["network"], bridge: settings["vb"]["bridge"], type: "dhcp"

    # VM hardware settings
    config.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", settings["vb"]["memory"]]
        vb.customize ["modifyvm", :id, "--cpus", settings["vb"]["cpus"]]
    end

    # Disable IPv6
    config.vm.provision "shell", inline: "sysctl -w net.ipv6.conf.all.disable_ipv6=1", run: "always"
    config.vm.provision "shell", inline: "sysctl -w net.ipv6.conf.default.disable_ipv6=1", run: "always"

    config.vm.provision "shell", inline: $packages
    config.vm.provision "shell", inline: $docker

    # Add defined SSH public key to vagrant user's authorized_keys
    if settings["vb"]["sshkey"]
        config.vm.provision "shell", inline: "echo \"#{settings['vb']['sshkey']}\" >> ~vagrant/.ssh/authorized_keys"
    end

end
