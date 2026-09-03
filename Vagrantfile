# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Base Ubuntu 22.04 LTS Box
  config.vm.box = "bento/ubuntu-22.04"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "cicd-bluegreen-vm"
    vb.memory = "2048"
    vb.cpus = 2
    # Ensure guest additions / VT-x compatibility
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  # Port Forwarding:
  # Nginx Main Entrypoint
  config.vm.network "forwarded_port", guest: 80, host: 80, auto_correct: true
  # Direct slot inspection
  config.vm.network "forwarded_port", guest: 8080, host: 8080, auto_correct: true
  config.vm.network "forwarded_port", guest: 8081, host: 8081, auto_correct: true

  # Shared folder to easily sync scripts and artifacts
  config.vm.synced_folder ".", "/vagrant"

  # Automatic Provisioning
  config.vm.provision "shell", inline: <<-SHELL
    set -e
    echo "===================================================="
    echo "  [PROVISIONING] Iniciando configuracion de la VM   "
    echo "===================================================="

    export DEBIAN_FRONTEND=noninteractive

    # Update packages
    apt-get update -y
    apt-get install -y openjdk-21-jdk nginx curl jq ufw net-tools

    # Create deployment directories
    mkdir -p /opt/app/blue
    mkdir -p /opt/app/green
    mkdir -p /opt/app/current
    mkdir -p /var/log/app
    chmod -R 777 /opt/app /var/log/app

    # Configure Nginx Reverse Proxy for Blue-Green
    cat << 'EOF' > /etc/nginx/sites-available/app.conf
upstream spring_backend {
    server 127.0.0.1:8080;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    location / {
        proxy_pass http://spring_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_connect_timeout 3s;
        proxy_read_timeout 10s;
    }
}
EOF

    # Enable custom configuration and disable default
    rm -f /etc/nginx/sites-enabled/default
    ln -sf /etc/nginx/sites-available/app.conf /etc/nginx/sites-enabled/app.conf

    # Restart Nginx
    nginx -t
    systemctl restart nginx
    systemctl enable nginx

    echo "===================================================="
    echo "  [PROVISIONING COMPLETADO] Java 21 y Nginx listos  "
    echo "===================================================="
  SHELL
end
