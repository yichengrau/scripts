#!/bin/bash
sudo apt-get -y update

sudo apt-get -y install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion

curl -L https://get.rvm.io | sudo bash -s stable

source /etc/profile

rvm install 1.9.3

rvm requirements

rvm use 1.9.3 --default

gem update --system

echo 'gem: --no-ri --no-rdoc' >> ~/.gemrc

gem install rails

sudo apt-get -y install g++ apache2-utils

git clone git://github.com/joyent/node.git

cd node

git checkout  v0.7.6-release

./configure

make

sudo make install

cd ..

sudo apt-get -y install mysql-server
sudo apt-get -y install libmysqlclient-dev
sudo apt-get -y install mysql-common
sudo apt-get -y install libpq5
sudo apt-get -y install libpcre3
sudo apt-get -y install libpcre3-dev

wget http://sphinxsearch.com/files/sphinx-2.0.4-release.tar.gz
tar xzvf sphinx-2.0.4-release.tar.gz
cd sphinx-2.0.4-release
./configure --prefix=/usr/local/sphinx 
sudo make
sudo make install
cd ..

rvmsudo gem install passenger

sudo apt-get -y install libcurl4-openssl-dev

rvmsudo passenger-install-nginx-module

wget -O init-deb.sh http://library.linode.com/assets/660-init-deb.sh

sudo mv init-deb.sh /etc/init.d/nginx

sudo chmod +x /etc/init.d/nginx

sudo /usr/sbin/update-rc.d -f nginx defaults

rvmsudo gem install sinatra

sudo apt-get -y install libmysql-ruby libmysqlclient-dev
