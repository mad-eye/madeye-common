#! /bin/sh

#For ubuntu
#Add APT repository
echo "deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main" | sudo tee /etc/apt/sources.list.d/opscode.list

#Add GPG Key and update index
sudo mkdir -p /etc/apt/trusted.gpg.d
gpg --keyserver keys.gnupg.net --recv-keys 83EF826A
gpg --export packages@opscode.com | sudo tee /etc/apt/trusted.gpg.d/opscode-keyring.gpg > /dev/null

#Upgrade packages
sudo apt-get update

#Install chef-server package
sudo apt-get install chef chef-server

#This will require some user responses
#Then...

#Configure Command Line Client
mkdir -p ~/.chef
sudo cp /etc/chef/validation.pem /etc/chef/webui.pem ~/.chef
sudo chown -R $USER ~/.chef

#You will need to open up the ports on Amazon.  open up 4000 and 4040

#Then configure command line client 'knife'
knife configure -i

