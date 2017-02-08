#!/bin/bash
######################################################
# rocketchat installation script for Centos/RHEL 7
# author: nicholas chung
# date: 12.8.16
# version 0.2
# instructions:
# 1. change root URLs
# 2. make script executable
# 3. run the script
# TODO: make interactive and retest dependencies
######################################################
# system update
yum -y update # system update
# add extra packages and update
yum -y install epel-release vim && yum -y update

# add mongodb repo with config below
touch /etc/yum.repos.d/mongodb-org-3.2.repo
cat <<'EOT' >> /etc/yum.repos.d/mongodb-org-3.2.repo
[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc
EOT
# end repo config

# install Rocket.Chat dependencies
yum install -y nodejs httpd curl GraphicsMagick npm mongodb-org-server mongodb-org gcc-c++
chkconfig mongod on

# install node dependencies
npm install -g inherits
npm install -g n

# install node version 4.5
n 4.5

# download Rocket.Chat files here
cd /opt
curl -L https://rocket.chat/releases/latest/download -o rocket.chat.tgz
tar -zxvf rocket.chat.tgz
mv bundle Rocket.Chat
cd Rocket.Chat/programs/server
npm install

# Add to systemd
cat <<'EOT' >> /usr/lib/systemd/system/rocketchat.service
[Unit]
Description=The Rocket.Chat server
After=network.target remote-fs.target nss-lookup.target httpd.target mongod.target
[Service]
ExecStart=/usr/local/bin/node /opt/Rocket.Chat/main.js
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=rocketchat
User=root
Environment=MONGO_URL=mongodb://localhost:27017/rocketchat ROOT_URL=http://192.168.100.239:3000/ PORT=3000
[Install]
WantedBy=multi-user.target
EOT
# end systemd config

# start and enable relevant services
systemctl start httpd
systemctl enable httpd
systemctl start mongod.service
systemctl enable mongod.service
systemctl start rocketchat.service
systemctl enable rocketchat.service
cd ../..
export PORT=3000
export ROOT_URL=http://192.168.100.239:3000/
export MONGO_URL=mongodb://localhost:27017/rocketchat
