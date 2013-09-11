#!/usr/bin/env bash

echo "changing sources.list to dutch mirror" 
sed -i 's/us.archive/nl.archive/' /etc/apt/sources.list

echo "changing locale to en_GB.UTF-8"
update-locale LC_ALL=en_GB.UTF-8 > /dev/null

echo "Updating sources"
apt-get update > /dev/null
echo "installing apt-add-repository" 
apt-get install python-software-properties -y > /dev/null 2>&1
echo "Adding PPA for git " 
apt-add-repository -y ppa:git-core/ppa > /dev/null 2>&1
echo "Updating sources again"
apt-get update > /dev/null 2>&1
echo "Upgrading system (might take a while)" 
apt-get upgrade -y > /dev/null 2>&1
echo "installing tools"
apt-get install zsh vim git rake build-essential curl -y  > /dev/null 2>&1

echo "setting default shell"
chsh -s /bin/zsh vagrant

echo "Installing clean"
cd /home/vagrant/
cp /vagrant/clean/clean2.4_64.tar.gz .
tar xzf clean2.4_64.tar.gz 

cd clean
make > /dev/null

cd ..

echo "installing dotfiles"
echo -n "  -> "
git clone https://github.com/thomwiggers/dotfiles.git .dotfiles
cd .dotfiles
echo "  -> initialising submodules"
git submodule update --init > /dev/null
echo "  -> updating submodules"
git submodule foreach git pull origin master > /dev/null 2>&1
echo "  -> Preparing for rake" 
export HOME=/home/vagrant
sed -i 's/username = gets/username = "Thom Wiggers"/' Rakefile
sed -i 's/email = gets/email = "foo@bar.com"/' Rakefile
sed -i 's@~@/home/vagrant@g' Rakefile
sed -i 's@$HOME@/home/vagrant@g' Rakefile
sed -i 's@overwrite_all = false@overwrite_all = true@' Rakefile
sed -i 's@#{ENV\["HOME"\]}@/home/vagrant@g' Rakefile

echo "  -> Running Rake"
rake > /dev/null

cd ..

echo "export PATH=$HOME/clean/bin/:$PATH" >> .zshrc

echo "Fixing owner of /home/vagrant"
sudo chown -R vagrant:vagrant /home/vagrant

echo "Removing cruft" 
rm postinstall.sh clean2.4_64.tar.gz .sudo_as_admin_successful .veewee_version .zcompdump* .vbox_version .zsh_history


