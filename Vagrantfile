Vagrant.configure("2") do |config|

  servers=[
    {
      :hostname => "douattarS",
      :box =>  "generic/alpine318",
      :ip => "192.168.56.110",
      :ssh_port => '2200',
      :login => "vagrant",
    },
    {
      :hostname => "douattarSW",
      :box =>  "generic/alpine318",
      :ip => "192.168.56.111",
      :ssh_port => '2201',
      :login => "vagrant",
    }
  ]

  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = machine[:box]
      node.ssh.insert_key = false
      node.vm.hostname = machine[:hostname]
      node.vm.provision "shell", inline: <<-SHELL
        echo "Setting up "
        apk update  && apk upgrade --no-cache 
        apk add mysql-client
        apk add mariadb
        apk add nginx
        apk add curl
        /etc/init.d/mariadb setup
        service mariadb start
        ip link add name eth1 type dummy
        ip addr add #{machine[:ip]}/24 dev eth1
        ip link set eth1 up

        echo "stream {
          upstream k3s_server {
            server 192.168.56.110:3000;
          }
          server {
            listen 6443;
            proxy_pass k43s_server;
          }" > /etc/nginx/nginx.conf

        # Install K3s
        curl -sfL https://get.k3s.io | sh -
        sudo k3s kubectl get node 
      SHELL
 #     node.vm.network :private_network, ip: machine[:ip]
 #     node.vm.network "forwarded_port", guest: 22, host: machine[:ssh_port], id: "ssh"
 #     node.ssh.username = machine[:login]
      config.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.gui = false
        v.cpus = 1
      end
      config.vm.boot_timeout = 600
        
    end
  end
end
