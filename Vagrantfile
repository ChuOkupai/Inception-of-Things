Vagrant.configure("2") do |config|
	config.vm.define "douattarS" do |control|
		
		config.vm.box = "alpine/alpine64"
		config.vm.provider "virtualbox" do |v|
		  v.memory = 1024
		  v.cpus = 1
		end
		config.vm.hostname = "douattarS"
		config.vm.network "public_network", ip: "192.168.56.110"
	end
	config.vm.define "douattarSW" do |control|
		config.vm.provider "virtualbox" do |v|
		  v.memory = 1024
		  v.cpus = 1
		end
		config.vm.box = "alpine/alpine64"
		config.vm.hostname = "douattarSW"
		config.vm.network "public_network", ip: "192.168.56.111"
	end
end
