class AccountsController < ApplicationController
  require 'starling'
  
  before_filter :authenticate_user!
  before_filter :authorized_user, :only => [:destroy]
  before_filter :load, :except => [:toggle_active]
  after_filter  :update_listener, :only => [:toggle_active, :destroy]
  
  respond_to :html, :js
  
  def load
    @user = current_user
    @accounts = @user.accounts
  end
  
  def create
    @account  = @user.accounts.build(params[:account])
    if @account.save
      flash[:success] = 'Account created!'
      redirect_to root_path
    else
      render 'pages/home'
    end
  end

  def destroy
    @account.destroy ?
      flash.now[:success] = 'Account deleted.' :
      flash.now[:error] = 'Error deleting account.'
    
    respond_with @account
  end
  
  def toggle_active
    @account = Account.find(params[:id])
    
    @account.update_attribute(:active, !@account.active)

    render :nothing => true
  end
  
  def index
    render 'pages/home'
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
      if @account.active && !@account.destroyed
        starling.set('idler_queue', %Q{
          start #{@account.id} #{@account.username} #{@account.token} #{@account.secret}
          }) if @account.user.listening 
      else
        starling.set('idler_queue', "stop #{@account.id}")
      end
    end

end
