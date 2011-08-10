class ContactsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorized_user, :except => [:index, :new, :create, :import]
  before_filter :load
  
  respond_to :html, :js
  
  def load
    @user = current_user
    @contacts = @user.contacts
  end

  def create
    params[:contact][:email] = params[:contact][:email].downcase
    @contact  = current_user.contacts.build(params[:contact])
    if @contact.save
      flash.now[:success] = "Contact created!"
    else
      flash.now[:error] = "Error creating contact. :("
    end
    
    respond_with @contact
  end

  def destroy
    @contact.destroy ?
      flash.now[:success] = "Contact deleted." :
      flash.now[:error] = "Error deleting contact."
    
    respond_with @contact
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
      flash[:success] = "Contact updated." :
      flash[:error] = "Error updating contact."
    redirect_to contacts_path
  end
  
  def toggle_active
    @contact = Contact.find(params[:id])
    
    @contact.update_attribute(:active, !@contact.active)

    render :nothing => true
  end
  
  def index
  end
  
  def import
    contact_emails = @contacts.map { |contact| contact.email }
    @emails = @user.accounts.map {|account| account.contacts }.flatten - contact_emails
    @emails.compact!
    @emails.uniq!
    @emails.sort!
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
