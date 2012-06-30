#!/bin/bash

rvmsudo gem install sinatra

./auto_deploy.rb -p 10304 &

