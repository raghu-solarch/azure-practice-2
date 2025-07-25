#!/bin/bash
sudo apt update
sudo apt install openjdk-17-jre-headless -y
sudo apt install maven -y

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y

java --version
mvn -v
jenkins --version

echo "All commands executed and server is ready."
