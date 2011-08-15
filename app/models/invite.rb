class Invite < ActiveRecord::Base
  
  attr_accessible :email, :approved
  
  after_create :notify_admin
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, :presence => true,
                    :format => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false }
                    
  
  private

    require 'notifo'

    # Used to notify admin of certain events.
    def notify_admin
      invites_url = 'http://www.vybit.com/invites/'

      notifo = Notifo.new("billiamram","notifo_key")
      notifo.post("billiamram", "Notifier Invitation Request", "New request from #{email}!", invites_url)
    end
end
