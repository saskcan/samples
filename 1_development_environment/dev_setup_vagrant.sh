#!/bin/bash
# Setup for Development Environment on Linux 12.04
# Written by James Neilson
echo "Update Installed Packages"
sudo apt-get update
echo "Use NFS to speed up sharing between guest and host"
sudo apt-get install nfs-common portmap
echo "Install curl"
sudo apt-get install -y curl
echo "Install Git Core"
sudo apt-get install -y git-core
echo "Install Node"
sudo apt-get install -y nodejs
echo "Install RVM"
\curl -L https://get.rvm.io | bash -s stable
source /usr/local/rvm/scripts/rvm
echo "Install RVM Requirements"
rvm requirements
echo "Install Ruby"
rvm install ruby-2.0.0-p353
rvm use ruby --default
rvm rubygems current
echo "Install Rails"
gem install rails --no-ri --no-rdoc
echo "Install imagemagick"
apt-get install -y imagemagick
echo "Install vim"
apt-get install -y vim
echo "Install screen"
apt-get install -y screen
echo "Install postgres"
sudo apt-get install -y libpq-dev
sudo apt-get install -y postgresql
echo "Configure postgres"
cd /etc/postgresql/9.1/main/
sed -i '90 c local   all             all                                     md5' pg_hba.conf
service postgresql restart
echo "Create a new database user"
sudo -u postgres createuser -S -R -I -d -l dishcount
sudo -u postgres psql -U postgres -c "alter user dishcount with password 'password1';"
cd /usr/local/rvm/gems
sudo chown -R vagrant:vagrant *
cd /srv/dishcount/
echo "Install foreman"
gem install foreman
echo "Install the bundle"
bundle install
echo "Create the database"
bundle exec rake db:create
echo "Migrate the database"
bundle exec rake db:migrate RAILS_ENV='development'
echo "Seed the database"
bundle exec rake db:seed:development
echo "Run the server"
foreman start -f Procfile.dev