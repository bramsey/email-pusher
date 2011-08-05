class AccountsController < ApplicationController
  require 'starling'
  
  before_filter :authenticate_user!
  before_filter :authorized_user, :only => [:edit, :destroy, :update, :new]
  before_filter :load, :except => [:toggle_active, :update_service]
  after_filter  :update_listener, :only => [:toggle_active]
  
  respond_to :html, :js
  
  def load
    @user = current_user
    @accounts = @user.accounts
  end
  
  def create
    @account  = current_user.accounts.build(params[:account])
    if @account.save
      flash[:success] = "account created!"
      redirect_to user_accounts_path( current_user )
    else
      render 'pages/home'
    end
  end

  def destroy
    @account.destroy ?
      flash.now[:success] = "Account deleted." :
      flash.now[:error] = "Error deleting account."
    
    respond_with @account
  end
  
  def edit
    @account = Account.find(params[:id])
  end
  
  def update
    @account = Account.find(params[:id])
    if params[:account][:notification_service_id].is_a?(String)
      params[:account][:notification_service_id] = params[:account][:notification_service_id].to_i
    end
    
    RAILS_DEFAULT_LOGGER.error params[:account][:notification_service_id]
    @account.update_attributes(params[:account]) ?
      flash[:success] = "Account updated." :
      flash[:error] = "Error updating account."
    redirect_to user_accounts_path( current_user )
  end
  
  def toggle_active
    @account = Account.find(params[:id])
    
    @account.update_attribute(:active, !@account.active)

    render :nothing => true
  end
  
  def update_service
    @account = Account.find(params[:id])
    service_id = params[:service_id]
    @account.update_attribute(:notification_service_id, service_id.to_i) unless service_id.nil?
    
    render :nothing => true
  end
  
  def index
    render 'pages/home'
  end
  
  def new
    @account = Account.new
  end
  

  private

    def authorized_user
      params[:user_id].nil? ? 
        @user = (@account = Account.find(params[:id])).user :
        @user = User.find(params[:user_id])
      redirect_to root_path unless current_user?(@user)
    end
    
    def update_listener
      starling = Starling.new('localhost:22122')
      if @account.active
        starling.set('idler_queue', 
          "start #{@account.id} #{@account.username}" +
          " #{@account.token} #{@account.secret}") if @account.user.listening 
      else
        starling.set('idler_queue', "stop #{@account.id}")
      end
    end

end
