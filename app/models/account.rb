class Account < ActiveRecord::Base
  attr_accessible :username, :active, :token, :secret, :notification_service_id
  
  attr_accessor :destroyed
  
  after_destroy :mark_as_destroyed
  #after_create :set_default_notification_service
  
  
  belongs_to :user
  belongs_to :notification_service
  
  validates :username, :presence => true
  validates :user_id, :presence => true
  
  def contacts
    require 'oauth'
    require 'oauth/consumer'
    require 'json'
    
    consumer ||= OAuth::Consumer.new(Configuration.google_consumer_key, 
                                      Configuration.google_consumer_secret,
                                      Configuration.google_consumer_params)
    
    access_token = OAuth::AccessToken.new(consumer, token, secret)
    
    response = access_token.get("https://www.google.com/m8/feeds/contacts/#{username}/full?alt=json&max-results=10000")

    if response.code == "200"
      results = JSON.parse(response.body)['feed']
    
      emails = results['entry'].map do |entry|
        next unless entry['gd$email']
        entry['gd$email'].first['address'].downcase
      end
      emails.compact!
      emails
    end
    emails ||= []
  end
  
  private
    
    def set_default_notification_service
      update_attribute(:notification_service_id, user.default_notification_service) unless user.default_notification_service.nil?
    end
    
    def mark_as_destroyed
      self.destroyed = true
    end
end
