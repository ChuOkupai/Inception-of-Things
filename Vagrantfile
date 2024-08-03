Vagrant.configure("2") do |config|
	config.vm.define "douattarS" do |douattarS|
		config.vm.box = "alpine/alpine64"
		config.vm.provider "virtualbox" do |v|
		  v.memory = 1024
		  v.cpus = 1
                  v.gui = false
		end
		config.vm.hostname = "douattarS"
		config.vm.network "public_network", ip: "192.168.56.110"
                douattarS.ssh.username = "vagrant"
                douattarS.ssh.password = "vagrant"
	end
	config.vm.define "douattarSW" do |douattarSW|
		config.vm.box = "alpine/alpine64"
		config.vm.provider "virtualbox" do |v|
		  v.memory = 1024
                  v.gui = false
		  v.cpus = 1
		end
		config.vm.hostname = "douattarSW"
		config.vm.network "public_network", ip: "192.168.56.111"
                douattarSW.ssh.username = "vagrant"
                douattarSW.ssh.password = "vagrant"
	end
end
