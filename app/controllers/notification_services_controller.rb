class NotificationServicesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorized_user
  require 'notifo'
  require 'json'
  
  respond_to :html, :js
  
  def index
    @user = User.find(params[:user_id])
    @notification_services = @user.notification_services
    
  end
  
  def new
    case params[:type]
    when "NotifoService"
      @notification_service = NotificationService.new(:user_id => current_user.id,
                                                      :type => "NotifoService")
    else
      @notification_service = nil
    end
  end
  
  def create
    username = params[:notification_service][:username]
    response = verify_notifo(username)
    if response['status'] == "success"
      @notification_service  = NotificationService.create(params[:notification_service])
      if @notification_service.save
        flash.now[:success] = "Service created!"
        current_user.update_attribute(:default_notification_service_id, @notification_service.id) if current_user.notification_services.all.length == 1
      else
        flash.now[:error] = "Notification Service not saved."
      end
    elsif response['response_code'] == 1105
      flash.now[:error] = "No such user found. Please check the id or register if needed."
    else
      flash.now[:error] = "Unable to verify Notifo account."
    end
    
    respond_with @notification_service
  end
  
  def edit
    @NotificationService = NotificationService.find(params[:id])
    render 'edit'
  end
  
  def update
    @notification_service = NotificationService.find(params[:id])
    username = params[:notifo_service][:username]
    if username == ""
      flash.now[:success] = "Notification Service Deleted" #put this in destroy action
      destroy
    else
      response = verify_notifo(username)
      if response['status'] == "success"
        @notification_service.update_attributes(params[:notifo_service]) ?
          flash.now[:success] = "Notification Service updated." :
          flash.now[:error] = "Notification Service not updated."
      elsif response['response_code'] == 1105
        @notification_service.errors.add(:username, " - No such user found. Please check the id or register if needed.")
      else
        @notification_service.errors.add(:username, " - Unable to verify Notifo account.")
      end
      respond_with @notification_service
    end 
  end
    
  
  def destroy
    current_user.update_attribute(:default_notification_service, nil) if current_user.default_notification_service == @notification_service
    @notification_service.destroy
    respond_with @notification_service
  end
  
  private
  
    def authorized_user
      if params[:user_id].nil?
        if !params[:notification_service].nil?
          @user = User.find(params[:notification_service][:user_id])
        else
          @user = (@notification_service = NotificationService.find(params[:id])).user
        end
      else
        @user = User.find(params[:user_id])
      end
      redirect_to root_path unless current_user?(@user)
    end
    
    def verify_notifo( username )
      notifo = Notifo.new("vybit", "fa9c05b25c34c8d5c364c8c9b400586ce5c60e4f")
      response = JSON( notifo.subscribe_user( username ) )
      #logger.info "response code: >#{response['response_code']}<"
    end
end
