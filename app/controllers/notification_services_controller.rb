class NotificationServicesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorized_user
  require 'notifo'
  
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
    @notification_service  = NotificationService.create(params[:notification_service])
    if @notification_service.save
      flash.now[:success] = "Service created!"
      #notifo = Notifo.new("vybly","notifo_key")
      #response = notifo.subscribe_user(@notification_service.username)
      #RAILS_DEFAULT_LOGGER.error response
      current_user.update_attribute(:default_notification_service_id, @notification_service.id) if current_user.notification_services.all.length == 1
    end
    
    respond_with @notification_service
  end
  
  def edit
    @NotificationService = NotificationService.find(params[:id])
    render 'edit'
  end
  
  def update
    @notification_service = NotificationService.find(params[:id])
    if params[:notifo_service][:username] == ""
      flash.now[:success] = "Notification Service Deleted"
      destroy
    elsif @notification_service.update_attributes(params[:notifo_service])
      flash.now[:success] = "Notification Service updated."
      #ToDo: insert trigger for notification here.
      respond_with @notification_service
    else
      flash[:error] = "Notification Service not updated."
      render 'edit'
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
end
