# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'
config_data = JSON.parse(File.read("clustering_config.json"))

master_ip   = config_data["master"]["ip"]
master_host = config_data["master"]["hostname"]
slave_ip    = config_data["slave"]["ip"]
slave_host  = config_data["slave"]["hostname"]

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.box_version = "202508.03.0"
  config.vm.synced_folder ".", "/vagrant"


  shared_host_folder = File.expand_path("shared", __dir__)
  Dir.mkdir(shared_host_folder) unless Dir.exist?(shared_host_folder)
  config.vm.synced_folder "./shared", "/shared", mount_options: ["dmode=777", "fmode=777"]
  config.vm.synced_folder "./provision/hadoop/configs", "/vagrant/configs"
  config.vm.synced_folder "./provision/scrapy/movie_scraper", "/home/vagrant/movie_scraper"
  config.vm.synced_folder "./provision/spark", "/vagrant/cleandata"
  config.vm.synced_folder "./flask_hdfs_ui", "/home/hadoopminhnhat/flask_hdfs_ui"

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

    master.vm.network "forwarded_port", guest: 2181, host: 2181
    master.vm.network "forwarded_port", guest: 9870, host: 9870
    master.vm.network "forwarded_port", guest: 8088, host: 8088
    master.vm.network "forwarded_port", guest: 8080, host: 8080
    master.vm.network "forwarded_port", guest: 8000, host: 8000
    master.vm.network "forwarded_port", guest: 8081, host: 8081
    master.vm.network "forwarded_port", guest: 9083, host: 9083
    master.vm.network "forwarded_port", guest: 8047, host: 8047
    master.vm.network "forwarded_port", guest: 9004, host: 9004
    master.vm.network "forwarded_port", guest: 10000, host: 10000


    master.vm.provider "virtualbox" do |vb|
      vb.name = master_host
      vb.memory = 2048
      vb.cpus = 2
    end
    master.vm.provision "shell", path: "provision/common.sh"
    master.vm.provision "shell", path: "provision/hadoop/hadoop_base.sh"
    master.vm.provision "shell", path: "provision/hadoop/hadoop_copy.sh"
    master.vm.provision "shell", path: "provision/hadoop/master_format.sh"

    # master.vm.provision "mongodb", type: "shell", path: "provision/mongodb/mongodb.sh"
    # master.vm.provision "spark", type: "shell", path: "provision/spark/spark.sh"
    # master.vm.provision "scrapy", type: "shell", path: "provision/scrapy/scrapy.sh"
    master.vm.provision "shell", path: "provision/mongodb/mongodb.sh", name: "mongodb"
    master.vm.provision "shell", path: "provision/scrapy/scrapy.sh", name: "scrapy"
    master.vm.provision "shell", path: "provision/spark/spark.sh", name: "spark"
    
    master.vm.provision "shell", path: "provision/hive/hive_base.sh"
    master.vm.provision "shell", path: "provision/hive/derby_base.sh"
    master.vm.provision "shell", path: "provision/hive/create_metastore.sh", name: "create_metastore"
    master.vm.provision "shell", path: "provision/webHDFS/webHDFS.sh", name: "webHDFS"
    master.vm.provision "shell", path: "provision/start-all-service.sh", run: "always", name: "start_all_service"
  end
end
