class Account < ActiveRecord::Base
  attr_accessible :username, :active, :token, :secret, :notification_service_id
  
  belongs_to :user
  belongs_to :notification_service
  
  validates :username, :presence => true
  validates :user_id, :presence => true
end
