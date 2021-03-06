#!/usr/bin/env ruby#this file should be put in the project directoryrequire "rubygems"require "sinatra"require "json"# Configure this with the directory path for the Web server's clone of the Git $#PROJECT_DIR = Dir.getwdPROJECT_DIR = '/home/ubuntu/deploy/agnes_rails'GIT_DIR = PROJECT_DIR + '/.git'# Configure the mappings between Git branches and Web document rootsbranch_to_working_directory = {'development' => PROJECT_DIR}count = 0

get '/' do
  "Hello World"
end

post '/' do
  push = JSON.parse(params[:payload])
  
  puts "COMMIT----[#{DateTime.now}]"
  
  puts "#{push}"
  
  ref = push['ref'] || raise("ref required in payload")
  branch = ref.match(/([^\/]+)$/)[0]
  work_dir = branch_to_working_directory[branch]
  
  puts "Got Github hook for ref #{ref}, branch #{branch}"
  
  if !work_dir.nil?
    puts "work_dir: #{work_dir}"
    
    commits = push['commits'][0]
    
    puts "Commits: #{commits}"
    
    added_files = commits["added"]
    modified_files = commits["modified"]
    removed_files = commits["removed"]
    
    all_changed_files = added_files + modified_files + removed_files
    
    need_reset_db = false
    
    all_changed_files.each do |f|
      need_reset_db = true if f.include?("db/migrate/")
    end
    
    puts "fetch new code..."
    
    # load the new code from remote repository
    puts `git --git-dir=#{GIT_DIR} --work-tree=#{work_dir} add .`
    puts `git --git-dir=#{GIT_DIR} --work-tree=#{work_dir} fetch`
    puts `git --git-dir=#{GIT_DIR} --work-tree=#{work_dir} reset --hard -q origin/#{branch}`
    
    puts "bundle install..."
    
    # bundle install
    puts`bundle install --gemfile=#{PROJECT_DIR}/Gemfile`
    
    if need_reset_db
      
      puts "refresh Database..."
      
      # update database
      puts `rake -f #{PROJECT_DIR}/Rakefile --trace db:drop`      puts `rake -f #{PROJECT_DIR}/Rakefile --trace db:create`      puts `rake -f #{PROJECT_DIR}/Rakefile --trace db:migrate`
      
      searchd_pid = nil      searchd_pid = `pgrep searchd`
      if !searchd_pid.nil?        puts `sudo kill -9 #{searchd_pid}`      end      puts "rebuild sphinx..."      puts `rake -f #{PROJECT_DIR}/Rakefile --trace ts:rebuild`
    end
    
    puts "restart server..."
    
    # stop nginx
    puts `sudo /etc/init.d/nginx stop`
    
    # start nginx
    puts `sudo /etc/init.d/nginx start`
  end
  
  puts "end...\n"
end



