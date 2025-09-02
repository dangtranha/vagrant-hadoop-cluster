# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
require 'json'
config_data = JSON.parse(File.read("clustering_config.json"))

master_ip   = config_data["master"]["ip"]
master_host = config_data["master"]["hostname"]
slave_ip    = config_data["slave"]["ip"]
slave_host  = config_data["slave"]["hostname"]

Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-24.04"
  config.vm.box_version = "202508.03.0"

  shared_host_folder = File.expand_path("shared", __dir__)
  Dir.mkdir(shared_host_folder) unless Dir.exist?(shared_host_folder)
  config.vm.synced_folder "./shared", "/shared", mount_options: ["dmode=777", "fmode=777"]
  config.vm.synced_folder "./provision/hadoop/configs", "/vagrant/configs"

  # Hadoop Slave
  config.vm.define "slave" do |slave|
    slave.vm.hostname = slave_host
    slave.vm.network "private_network", ip: slave_ip
    slave.vm.provider "virtualbox" do |vb|
      vb.name = slave_host
      vb.memory = 1024
      vb.cpus = 1
    end
    slave.vm.provision "shell", path: "provision/common.sh"
    slave.vm.provision "shell", path: "provision/hadoop/hadoop_base.sh"
    slave.vm.provision "shell", path: "provision/hadoop/hadoop_copy.sh"
  end

  # Hadoop Master
  config.vm.define "master" do |master|
    master.vm.hostname = master_host
    master.vm.network "private_network", ip: master_ip
    master.vm.network "forwarded_port", guest: 9870, host: 9870
    master.vm.network "forwarded_port", guest: 8088, host: 8088
    master.vm.provider "virtualbox" do |vb|
      vb.name = master_host
      vb.memory = 2048
      vb.cpus = 2
    end
    master.vm.provision "shell", path: "provision/common.sh"
    master.vm.provision "shell", path: "provision/hadoop/hadoop_base.sh"
    master.vm.provision "shell", path: "provision/hadoop/hadoop_copy.sh"
    master.vm.provision "shell", path: "provision/hadoop/master_format.sh"
  end
end