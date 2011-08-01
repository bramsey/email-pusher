class Account < ActiveRecord::Base
  attr_accessible :username, :active, :token, :secret, :notification_service_id
  
  after_create :set_default_notification_service
  
  belongs_to :user
  belongs_to :notification_service
  
  validates :username, :presence => true
  validates :user_id, :presence => true
  
  private
    
    def set_default_notification_service
      update_attribute(:notification_service_id, user.default_notification_service) unless user.default_notification_service.nil?
    end
end
