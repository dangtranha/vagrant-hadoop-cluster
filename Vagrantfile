# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  # General vagrant settings
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.box_version = "202508.03.0"
  
  # Shared folder
  config.vm.synced_folder "./shared", "/shared", mount_options: ["dmode=777", "fmode=777"]

  # Hadoop Master
  config.vm.define "master" do |master|
    master.vm.hostname = "hadoop-master"
    master.vm.network "private_network", ip: "192.168.56.10"
    master.vm.network "forwarded_port", guest: 9870, host: 9870   # NameNode
    master.vm.network "forwarded_port", guest: 8088, host: 8088   # YARN
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
    end
    # master.vm.provision "shell", path: "provision/common.sh"
    # master.vm.provision "shell", path: "provision/hadoop.sh"
  end

  # Hadoop Slaves
  config.vm.define "hadoop-slave" do |node|
      node.vm.host_name = "hadoop-slave"
      node.vm.network "private_network", ip: "192.168.56.20"
      node.vm.provider "virtualbox" do |vb|
        vb.name = "hadoop-slave"
        vb.memory = 512
      end
    end
  config.vm.provision "shell",  inline: <<-SHELL
    sudo apt-get update
  SHELL
end
