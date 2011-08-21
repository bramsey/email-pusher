class UsersController < ApplicationController
  require 'starling'
  
  before_filter :authenticate_user!,      :except => [:new, :create, :init]
  before_filter :correct_user,      :only => [:edit, :update, :toggle_listening]
  before_filter :admin_user, :only => [:index, :show]
  after_filter  :update_listener, :only => [:toggle_listening]

  def index
    @users = User.all
  end
  
  def edit
    @user = current_user
  end
  
  def show
    @user = User.find( params[:id] )
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def toggle_listening
    @user = User.find(params[:id])
    
    @user.update_attribute(:listening, !@user.listening)

    render :nothing => true
  end
  
  def init
    sender = params[:sender]
    recipient = params[:recipient]

    subject = params[:subject] || "no subject provided"
    account = Account.find_by_email( recipient.downcase )
    @user = account.user unless account.nil?
    unless (sender.nil? || @user.nil?)
      if @user.has_active_contact?(sender.downcase)
        @user.default_notification_service.notify(sender, subject, recipient) if 
          @user.default_notification_service_id
        @response = "notification sent at #{Time.now}"
        render :text => @response
      else
        logger.info "no active contact."
        render :text => 'denied'
      end 
    else
      logger.info "sender or user nil."
      render :text => 'denied'
    end
  end

  def destroy
    unless current_user?(User.find(params[:id]))
      User.find(params[:id]).destroy
      flash[:success] = "User destroyed."
    else
      flash[:error] = "Deletion of signed in user not allowed."
    end
    redirect_to users_path
  end
  

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def already_signed_in
      redirect_to(root_path) if user_signed_in?
    end
    
    def update_listener
      starling = Starling.new('localhost:22122')
      if @user.listening
        @user.accounts.each do |account|
          if account.active
            starling.set('idler_queue', 
                         "start #{account.id} #{account.username}" +
                         " #{account.token} #{account.secret}")
          end
        end 
      else
        @user.accounts.each {|account| starling.set('idler_queue', "stop #{account.id}")}
      end
    end
end
