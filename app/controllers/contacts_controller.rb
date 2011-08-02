class ContactsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorized_user, :except => [:index, :new, :create]

  def create
    @contact  = current_user.contacts.build(params[:contact])
    if @contact.save
      flash[:success] = "contact created!"
      redirect_to contacts_path
    else
      render 'pages/home'
    end
  end

  def destroy
    @contact.destroy ?
      flash[:success] = "contact deleted." :
      flash[:error] = "Error deleting contact."
    redirect_to contacts_path
  end
  
  def edit
    @contact = Contact.find(params[:id])
  end
  
  def update
    @contact = Contact.find(params[:id])
    if params[:contact][:notification_service_id].is_a?(String)
      params[:contact][:notification_service_id] = params[:contact][:notification_service_id].to_i
    end
    
    RAILS_DEFAULT_LOGGER.error params[:contact][:notification_service_id]
    @contact.update_attributes(params[:contact]) ?
      flash[:success] = "contact updated." :
      flash[:error] = "Error updating contact."
    redirect_to contacts_path
  end
  
  def toggle_active
    @contact = Contact.find(params[:id])
    
    @contact.update_attribute(:active, !@contact.active)

    render :nothing => true
  end
  
  def index
    @user = current_user
    @title = "contacts"
    @contacts = @user.contacts
  end
  
  def new
    @contact = Contact.new
  end
  

  private

    def authorized_user
      params[:user_id].nil? ? 
        @user = (@contact = Contact.find(params[:id])).user :
        @user = User.find(params[:user_id])
      redirect_to root_path unless current_user?(@user)
    end
end
