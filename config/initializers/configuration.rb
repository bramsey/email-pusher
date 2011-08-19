class Configuration
  class << self
    attr_accessor :notifo_service_user, 
                  :notifo_service_key, 
                  :notifo_admin_user,
                  :notifo_admin_key,
                  :google_consumer_key,
                  :google_consumer_secret,
                  :google_consumer_params
  end
end
