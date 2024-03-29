ENV['RAILS_ENV'] ||= 'production'
require File.join(File.dirname(__FILE__), '..', 'config', 'environment')

RUBY = '[ruby_path]' # Production path
DIR = File.dirname(__FILE__)

puts "dir: #{DIR}"


def init
  Account.all.each do |account|
    if account.active && account.user.listening
      puts "starting #{account.id}"
      start( account.id, account.username, account.token, account.secret)
    else
      puts "stopping #{account.id}"
      stop( account.id )
    end
  end
end

def start( account, username, token, secret)
  %x[#{RUBY} #{DIR}/idle_ctl.rb stop #{account}]
  %x[#{RUBY} #{DIR}/idle_ctl.rb start #{account} -- #{username} #{token} #{secret}]
end

def stop( account )
  %x[#{RUBY} #{DIR}/idle_ctl.rb stop #{account}]
end

starling = Starling.new('127.0.0.1:22122')

init

loop do
  command = starling.get('idler_queue')
  puts command unless command.nil?
  action = command.split[0]
  account = command.split[1]
  
  case action
  when "start"
    start( account, command.split[2], command.split[3], command.split[4] )
  when "stop"
    stop( account )
  else
    puts "invalid command"
  end
  
  sleep 1
  #listen for new commands on the queue.
  
  
  
  #parse the commands and take the appropriate actions.
  # example actions:
  #   start a new account checking process
  #   stop a running account checking process
  #   update account information (restart with new information basically)
  #   add process to the hash or whatever is used to track them
end

