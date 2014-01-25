# -*- mode: ruby -*-
# vi: set ft=ruby :

$LOAD_PATH << "."
require "Params"

params = Params.get
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "debian-7.2.0"
  config.vm.box_url = "https://dl.dropboxusercontent.com/u/197673519/debian-7.2.0.box"

  config.vm.network :private_network, ip: params["server_ip"]
  config.vm.synced_folder params["www_dir"], "/var/www", create: true, owner: "www-data", group: "www-data"

  config.vm.provider :virtualbox do |vb|
    vb.gui = false
    vb.customize ["modifyvm", :id, "--memory", params["memory"]]
  end

  config.vm.provision "shell" do |s|
	s.path = Params::PROVISION_DIR + "/init.sh"
	s.args = "--server_ip=" + params["server_ip"]
  end
end
