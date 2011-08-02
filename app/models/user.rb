class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :remember_me, :password, :default_notification_service
  
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
end
