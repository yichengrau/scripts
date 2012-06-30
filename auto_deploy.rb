#!/usr/bin/env ruby

require "rubygems"
require "sinatra"
require "json"

# Configure this with the directory path for the Web server's clone of the Git repo
git_dir = '/home/peter/projects/agnes_rails/.git'

# Configure the mappings between Git branches and Web document roots
branch_to_working_directory = {
  'master' => '/home/peter/deploy/agnes_rails',
  'development' => '/home/peter/projects/agnes_rails',
  'messages_api' => '/home/peter/projects/agnes_rails',
}

count = 0

get '/' do
  "Hello World"
end

post '/' do
  push = JSON.parse(params[:payload])

  print "#{push}"

  ref = push['ref'] || raise("ref required in payload")
  branch = ref.match(/([^\/]+)$/)[0]
  work_dir = branch_to_working_directory[branch]
  warn "Got Github hook for ref #{ref}, branch #{branch}, work_dir #{work_dir}"
  
# load the new code from remote repository
  system "git --git-dir=#{git_dir} --work-tree=#{work_dir} add ."
  system "git --git-dir=#{git_dir} --work-tree=#{work_dir} fetch"
  system "git --git-dir=#{git_dir} --work-tree=#{work_dir} reset --hard -q origin/#{branch}"
  ''

# update database
  system "rake -f #{work_dir}/Rakefile db:migrate"

# stop nginx
  system "echo 1414 | sudo -S /etc/init.d/nginx stop"

# start nginx
  system "echo 1414 | sudo -S /etc/init.d/nginx start"

end