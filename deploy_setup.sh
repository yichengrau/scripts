#! /bin/sh

eval `ssh-agent`

ssh-add

nohup ruby -rubygems ./auto_deploy.rb  -p 10304 &

sudo /etc/init.d/nginx stop
sudo /etc/init.d/nginx start