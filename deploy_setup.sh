#!/bin/bash

rvmsudo gem install sinatra

eval `ssh-agent`

ssh-add

nohup ruby -rubygems ./auto_deploy.rb  -p 10304 &

nohup rvmsudo rake ts:dd &
