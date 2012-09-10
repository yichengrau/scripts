#!/usr/bin/env ruby

#this file should be put in the project directory

require "rubygems"
require "sinatra"
require "json"

# Configure this with the directory path for the Web server's clone of the Git repo
PROJECT_DIR = Dir.getwd
GIT_DIR = PROJECT_DIR + '/.git'

need_reset_db = false

# Configure the mappings between Git branches and Web document roots
branch_to_working_directory = {
'master' => PROJECT_DIR,
'development' => PROJECT_DIR,
'deploy_script' => PROJECT_DIR
}

count = 0

get '/' do
"Hello World"
end

post '/' do
push = JSON.parse(params[:payload])

print "#{push}\n\n"

ref = push['ref'] || raise("ref required in payload")
branch = ref.match(/([^\/]+)$/)[0]
work_dir = branch_to_working_directory[branch]
warn "Got Github hook for ref #{ref}, branch #{branch}, work_dir #{work_dir}"

commits = push['commits'][0]

print "#{commits}\n\n"

added_files = commits["added"]
modified_files = commits["modified"]
removed_files = commits["removed"]

all_changed_files = added_files + modified_files + removed_files

all_changed_files.each do |f|
  need_reset_db = true if f.include?("db/migrate/")
end

# load the new code from remote repository
system "git --git-dir=#{GIT_DIR} --work-tree=#{work_dir} add ."
system "git --git-dir=#{GIT_DIR} --work-tree=#{work_dir} fetch"
system "git --git-dir=#{GIT_DIR} --work-tree=#{work_dir} reset --hard -q origin/#{branch}"

# bundle install
`bundle install`

if need_reset_db

  # update database
  `rake db:drop`
  `rake db:create`
  `rake db:migrate`
  
  #search engine re-index
  searchd_pid_str = `cat #{PROJECT_DIR}/log/searchd.*.pid`
  
  print "searchd_pid_str: [#{searchd_pid_str}]\n\n"
  
  
  if !searchd_pid_str.nil?
    `rake ts:stop`
  end
  
  `rake ts:index`
  `rake ts:start`
  
end

# stop nginx
`sudo /etc/init.d/nginx stop`

# start nginx
`sudo /etc/init.d/nginx start`

end