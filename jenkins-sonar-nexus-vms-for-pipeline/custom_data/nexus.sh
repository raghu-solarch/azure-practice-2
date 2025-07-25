#!/bin/bash
sudo apt update

sudo su <<EOF
adduser --disabled-password --gecos "" nexus
echo "nexus:12345" | chpasswd
cd /opt
mkdir sonatype
chown -R nexus:nexus sonatype
cd sonatype
wget https://download.sonatype.com/nexus/3/nexus-3.81.1-01-linux-x86_64.tar.gz
tar xvzf nexus-3.81.1-01-linux-x86_64.tar.gz
chown -R nexus:nexus *
mv nexus-3.81.1-01 nexus
cat > /etc/systemd/system/nexus.service <<SERVICE
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/sonatype/nexus/bin/nexus start
ExecStop=/opt/sonatype/nexus/bin/nexus stop
User=nexus
Restart=on-abort
TimeoutSec=600

[Install]
WantedBy=multi-user.target
SERVICE

sudo systemctl daemon-reload
sudo systemctl enable nexus.service
sudo systemctl start nexus.service
sudo systemctl status nexus.service
EOF

echo "All commands executed and server is ready."
