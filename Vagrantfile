# -*- mode: ruby -*-
# vi: set ft=ruby :

require File.dirname(__FILE__) + '/Params.rb'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "debian-7.2.0"
  config.vm.box_url = "https://dl.dropboxusercontent.com/u/197673519/debian-7.2.0.box"
  
  #config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :private_network, ip: "192.168.2.10"

  config.vm.synced_folder WWW_DIR, "/var/www", create: true,
	owner: "www-data", group: "www-data"

  config.vm.provider :virtualbox do |vb|
    vb.gui = false
    vb.customize ["modifyvm", :id, "--memory", VM_MEMORY]
  end
  
  config.vm.provision "shell" do |s|
	s.path = PROVISION_DIR + "/init.sh"
  end
end
