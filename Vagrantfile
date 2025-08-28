# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.box_version = "202508.03.0"

  shared_host_folder = File.expand_path("shared", __dir__)
  Dir.mkdir(shared_host_folder) unless Dir.exist?(shared_host_folder)
  config.vm.synced_folder "./shared", "/shared", mount_options: ["dmode=777", "fmode=777"]

  # Hadoop Master
  config.vm.define "master" do |master|
    master.vm.hostname = "hadoop-master"
    master.vm.network "private_network", ip: "192.168.56.10"
    master.vm.network "forwarded_port", guest: 9870, host: 9870
    master.vm.network "forwarded_port", guest: 8088, host: 8088
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
    end
    # master.vm.provision "shell", path: "provision/common.sh"
  end

  # # Hadoop Slave
  # config.vm.define "slave" do |node|
  #   node.vm.hostname = "hadoop-slave"       # đúng cú pháp
  #   node.vm.network "private_network", ip: "192.168.56.20"
  #   node.vm.provider "virtualbox" do |vb|
  #     vb.name = "hadoop-slave"
  #     vb.memory = 512
  #   end
  # end
  config.vm.provision "shell", path: "provision/common.sh"
  #config.vm.provision "shell", path: "provision/hadoop/hadoop_base.sh"
end

