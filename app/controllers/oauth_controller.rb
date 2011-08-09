class OauthController < ApplicationController
  require 'oauth'
  require 'oauth/consumer'
  require 'json'
  
  before_filter :init_session, :only => [:google, :auth]
  
  def google
    @request_token = @consumer.get_request_token(:oauth_callback => "#{root_url}oauth/auth")
    session[:oauth][:request_token] = @request_token.token
    session[:oauth][:request_token_secret] = @request_token.secret
    redirect_to @request_token.authorize_url
  end
  
  def auth
        
    begin
      @access_token = @request_token.get_access_token({:oauth_verifier => params[:oauth_verifier]})
    RAILS_DEFAULT_LOGGER.error "post access token creation"
    
    rescue
      flash[:error] = "Authorization denied"
    end
    
    if @access_token
      response = @access_token.get('https://www.googleapis.com/userinfo/email?alt=json')
      if response.is_a?(Net::HTTPSuccess)
        @email = JSON.parse(response.body)['data']['email']
        logger.error "response success for #{@email}"
      else
        logger.error "could not get email: #{response.inspect}"
      end
      
      @account = Account.find_by_username(@email)
      if @account
        @account.update_attributes(:token => @access_token.token, :secret => @access_token.secret)
        flash["success"] = "#{@email} linked successfully."
      else
        logger.error "account not found for: #{@email}, trying to create new one."
        
        account_params = {
          :username => @email,
          :token => @access_token.token,
          :secret => @access_token.secret
        }
        @account = current_user.accounts.build(account_params)
        if @account.save
          flash[:success] = "#{@email} linked successfully."
        else
          flash[:error] = "Could not create account with the returned credentials"
          logger.error "could not create account for #{@email}"
        end
      end
      
      session[:oauth][:access_token] = @access_token.token
      session[:oauth][:access_token_secret] = @access_token.secret
    else
      logger.error "access token not generated"
      flash[:error] = "Authorization denied"
    end
    
    session[:oauth] = {}
    
    redirect_to root_url
  end
  
  private
    
    def init_session
      session[:oauth] ||= {}

      @consumer ||= OAuth::Consumer.new(Configuration.google_consumer_key, 
                                        Configuration.google_consumer_secret,
                                        Configuration.google_consumer_params)

      if !session[:oauth][:request_token].nil? && !session[:oauth][:request_token_secret].nil?
        @request_token = OAuth::RequestToken.new(@consumer, session[:oauth][:request_token], session[:oauth][:request_token_secret])
      end

      if !session[:oauth][:access_token].nil? && !session[:oauth][:access_token_secret].nil?
        @access_token = OAuth::AccessToken.new(@consumer, session[:oauth][:access_token], session[:oauth][:access_token_secret])
      end
    end
  
end
