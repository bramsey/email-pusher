class NotificationServicesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorized_user
  require 'notifo'
  
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
      flash[:success] = "Service created!"
      notifo = Notifo.new("vybly","notifo_key")
      response = notifo.subscribe_user(@notification_service.username)
      RAILS_DEFAULT_LOGGER.error response
      current_user.update_attribute(:default_notification_service_id, @notification_service.id) if current_user.notification_services.all.length == 1
      redirect_to root_path
    else
      render 'pages/home'
    end
  end
  
  def edit
    @NotificationService = NotificationService.find(params[:id])
    render 'edit'
  end
  
  def update
    @NotificationService = NotificationService.find(params[:id])
    if @NotificationService.update_attributes(params[:NotificationService])
      flash[:success] = "Notification Service updated."
      #ToDo: insert trigger for notification here.
      redirect_to root_path
    else
      flash[:error] = "Notification Service not updated."
      render 'edit'
    end
  end
    
  
  def destroy
    current_user.update_attribute(:default_notification_service, nil) if current_user.default_notification_service == @notification_service
    @notification_service.destroy
    redirect_back_or user_notification_services_path(current_user) 
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
