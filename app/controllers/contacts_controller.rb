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
    if params[:contact]
      params[:contact][:email] = params[:contact][:email].downcase
      @contact  = @user.contacts.build(params[:contact])
      @contact.save ?
        flash.now[:success] = "Contact created!" :
        flash.now[:error] = "Error creating contact. :("
    
      respond_with @contact
    elsif params[:contacts]
      contacts = params[:contacts].split( ',' )
      errors_found = false
      contacts.each do |contact| 
        errors_found = true unless @user.contacts.build(:user_id => @user.id, :email => contact.downcase ).save
      end 
      errors_found ?
        flash[:error] = "Error creating contacts. :(" :
        flash[:success] = "Contacts created!"
        
      redirect_to contacts_path
    end
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
