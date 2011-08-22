class NotificationServicesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorized_user
  before_filter :load, :only => [:edit, :destroy, :update]
  
  respond_to :html, :js
  
  def index
    @user = User.find(params[:user_id])
    @notification_services = @user.notification_services
    
  end
  
  def new
    case params[:type]
    when "NotifoService"
      @notification_service = NotificationService.new(:user_id => current_user.id,
                                                      :type => 'NotifoService')
    else
      @notification_service = nil
    end
  end
  
  def create
    @notification_service  = NotificationService.create(params[:notification_service])
    if @notification_service.save
      flash.now[:success] = 'Service created!'
      current_user.update_attribute(:default_notification_service_id, 
                                    @notification_service.id)
    else
      @notification_service.errors ?
        flash.now[:error] = @notification_service.errors.first :
        flash.now[:error] = 'Notification Service not saved.'
    end
    
    respond_with @notification_service
  end
  
  def edit
    render 'edit'
  end
  
  def update
    if params[:notifo_service][:username] == ""
      destroy
    else
      @notification_service.update_attributes(params[:notifo_service]) ?
        flash.now[:success] = 'Notification Service updated.' :
        flash.now[:error] = 'Notification Service not updated.'
        
      respond_with @notification_service
    end 
  end
    
  
  def destroy
    current_user.update_attribute(:default_notification_service, nil) if 
      current_user.default_notification_service == @notification_service
    @notification_service.destroy ?
      flash.now[:success] = 'Notification Service deleted' :
      flash.now[:success] = 'Notification Service not deleted.'
      
    respond_with @notification_service
  end
  
  private
  
    def load
      @notification_service = NotificationService.find(params[:id])
    end
    
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
