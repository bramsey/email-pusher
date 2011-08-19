if !(ARGV.length >= 2)
  puts "usage: ruby <script> <username> <token> <secret>"
  ARGV.each {|arg| puts "#{arg}<"}
  exit
end

SERVER = 'imap.gmail.com' # parameterize when supporting other hosts)
HOST_URL = 'http://www.vybit.com'
USERNAME = ARGV[0] unless ARGV[0].nil?
CONSUMER_KEY = 'anonymous'
CONSUMER_SECRET = 'anonymous'
TOKEN = ARGV[1] unless ARGV[1].nil?
SECRET = ARGV[2] unless ARGV[2].nil?
NOTIFO_USER = 'billiamram'
NOTIFO_SECRET = 'notifo_key'


require 'mail'
require 'time'
require 'date'
require 'net/http'
require 'gmail_xoauth'
require 'notifo'

# Extend support for idle command. See online.
# http://www.ruby-forum.com/topic/50828
# but that was wrong. see /opt/ruby-1.9.1-p243/lib/net/imap.rb.
class Net::IMAP
  def idle
    puts 'starting idle'
    cmd = "IDLE"
    synchronize do
      @idle_tag = generate_tag
      put_string(@idle_tag + " " + cmd)
      put_string(CRLF)
    end
  end

  def say_done
    cmd = "DONE"
    synchronize do
      put_string(cmd)
      put_string(CRLF)
    end
  end

  def await_done_confirmation
    synchronize do
      get_tagged_response(@idle_tag, nil)
      puts 'just got confirmation'
    end
  end
end

class MailReader
  attr_reader :imap

  public
  def initialize
    @imap = nil
    start_imap
  end

  # Process incoming messages.
  def process
    puts "checking #{USERNAME}."
    @highest_id ||= 0 # Used to prevent overlap of checking the same messages.
    msg_ids = @imap.search(["UNSEEN", "UNFLAGGED"])
    msg_ids ||= []
    puts "found #{msg_ids.length} messages"

    msg_ids.each do |msg_id|
      next unless msg_id.to_i > @highest_id
      @highest_id = msg_id.to_i
      mail = Mail.new( @imap.fetch(msg_id, 'RFC822').first.attr['RFC822'] )
      @imap.store msg_id, '-FLAGS', [:Seen]
      
      puts "New mail from #{mail.from.first}:"
      
      # Flags will be true if desired condition is met.
      toFlag = mail.to.join.downcase.include? USERNAME.downcase
      noReplyFlag = !(mail.from.collect {|e| e.include?("noreplys")}.include?(true))
      listFlag = mail.header['List-Unsubscribe'].nil? && mail.header['List-Id'].nil?
      
      processFlag = toFlag && noReplyFlag && listFlag
      
      
      if processFlag # Ensure the proper conditions are met.
          
        response = send_init( mail.from.first, mail.subject )
        puts "direct response: #{response}"
        @imap.store msg_id, '+FLAGS', [:flagged] unless response == "denied"
      end 
    end
  end
  
  # Post the initialization call to the rails server.
  def send_init( sender, subject )
    url = URI.parse("#{HOST_URL}/users/init")
    subject ||= ""
    post_args = { :sender => sender,
                  :recipient => USERNAME,
                  :subject => subject }
    
    response, data = Net::HTTP.post_form( url, post_args )
    
    response.code == "200" ? data : "#{response.code}"
  end

  def tidy
    stop_imap
  end

  def bounce_idle
    # Bounces the idle command.
    @imap.say_done
    @imap.await_done_confirmation
    process
    @imap.idle
  end

  private
  def start_imap
    @imap = Net::IMAP.new SERVER, ssl: true

    @imap.authenticate('XOAUTH', USERNAME, 
        :consumer_key => CONSUMER_KEY, 
        :consumer_secret => CONSUMER_SECRET, 
        :token => TOKEN, 
        :token_secret => SECRET
      )
    @imap.select 'INBOX'

    # Add handler.
    @imap.add_response_handler do |resp|
      if resp.kind_of?(Net::IMAP::UntaggedResponse) and resp.name == "EXISTS"
        @imap.say_done
        Thread.new do
          @imap.await_done_confirmation
          process
          @imap.idle
        end
      end
    end

    process
    @imap.idle
  end

  def stop_imap
    @imap.done
  end
end

# Sends notifo message to admin for use in error notification.
def notify_admin( message )
  notifo = Notifo.new( NOTIFO_USER, NOTIFO_SECRET )
  notifo.post( "billiamram", "Idle.rb error", message )
end

reader = MailReader.new

loop do
  sleep 10*60
  puts "bouncing account #{USERNAME}"
  
  # Error checking.
  begin
    reader.bounce_idle
  rescue Net::IMAP::NoResponseError => e
    File.open( "#{USERNAME}.err.log", 'a' ) {|f| f.write(e.message) }
    notify_admin e.message
  rescue Net::IMAP::ByeResponseError => e
    File.open( "#{USERNAME}.err.log", 'a' ) {|f| f.write(e.message) }
    notify_admin e.message
  rescue => e
    File.open( "#{USERNAME}.err.log", 'a' ) do |f| 
      f.write(e.message)
      f.write(e.backtrace)
    end
    notify_admin e.message
  end
end