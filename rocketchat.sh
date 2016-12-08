#!/bin/bash
######################################################
# rocketchat installation script for Centos/RHEL 7
# author: nicholas chung
# date: 12.8.16
# version 0.1
######################################################
sudo yum -y update # system update
sudo yum -y install epel-release vim && sudo yum -y update # add extra packages and update
touch /etc/yum.repos.d/mongodb-org-3.2.repo # add mongodb repo with config below
cat > /etc/yum.repos.d/mongodb-org-3.2.repo << EOL
[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc
EOL # end repo config
sudo yum install -y nodejs httpd curl GraphicsMagick npm mongodb-org-server mongodb-org gcc-c++ # install Rocket.Chat dependencies
sudo chkconfig mongod on
sudo npm install -g inherits # install node dependencies
sudo npm install -g n
sudo n 4.5 # install node version 4.5
cd /opt # download Rocket.Chat files here
sudo curl -L https://rocket.chat/releases/latest/download -o rocket.chat.tgz
sudo tar -zxvf rocket.chat.tgz
sudo mv bundle Rocket.Chat
cd Rocket.Chat/programs/server
sudo npm install
cat > /usr/lib/systemd/system/rocketchat.service << EOL
[Unit]
Description=The Rocket.Chat server
After=network.target remote-fs.target nss-lookup.target httpd.target mongod.target
Service]
ExecStart=/usr/local/bin/node /opt/Rocket.Chat/main.js
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=rocketchat
User=root
Environment=MONGO_URL=mongodb://localhost:27017/rocketchat ROOT_URL=http://192.168.100.239:3000/ PORT=3000 # change IP address
[Install]
WantedBy=multi-user.target
EOL # end systemd config
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl start mongod.service
sudo systemctl enable mongod.service
sudo systemctl start rocketchat.service
sudo systemctl enable rocketchat.service
cd ../..
export PORT=3000
export ROOT_URL=http://192.168.100.239:3000/
export MONGO_URL=mongodb://localhost:27017/rocketchat
