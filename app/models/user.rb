class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :remember_me, :password, :default_notification_service
  
  after_create :notify_admin
  
  has_many :accounts, :dependent => :destroy
  has_many :contacts, :dependent => :destroy
  has_many :notification_services, :dependent => :destroy
  
  belongs_to :default_notification_service, :class_name => "NotificationService"
  
  def self.find_for_open_id(access_token, signed_in_resource=nil)
    data = access_token['user_info']
    if user = User.find_by_email(data["email"])
      user
    else # Create a user with a stub password.
      User.create!(:email => data["email"], :password => Devise.friendly_token[0,20])
    end
  end
  
  def has_active_contact?( contact_email )
    contact = contacts.find_by_email(contact_email)
    contact ? contact.active : false
  end
  
  def approved?
    invite = Invite.find_by_email email
    invite ? invite.approved : false
  end
  
  private
    
    require 'notifo'
    
    # Used to notify admin of certain events.
    def notify_admin
      url_path = "http://www.vybit.com/users"

      notifo = Notifo.new("billiamram","notifo_key")
      notifo.post("billiamram", "Notifier User Creation", "New signup from #{email}!", url_path)
    end
end
