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
    if params[:contact] # When creating one contact.
      params[:contact][:email] = params[:contact][:email].downcase
      create_contact( params[:contact] )
    elsif params[:contacts] # When creating multiple contacts.
      create_contacts( params[:contacts] )
    end
  end

  def destroy
    @contact.destroy ?
      flash.now[:success] = 'Contact deleted.' :
      flash.now[:error] = 'Error deleting contact.'
    
    respond_with @contact
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
    
    def create_contact( contact_params )
      @contact  = @user.contacts.build(params[:contact])
      @contact.save ?
        flash.now[:success] = 'Contact created!' :
        flash.now[:error] = 'Error creating contact.'

      respond_with @contact
    end
    
    def create_contacts( contacts_params )
      contacts = contacts_params.split( ',' )
      errors_found = false
      contacts.each do |contact| 
        errors_found = true unless 
          @user.contacts.build(:user_id => @user.id, :email => contact.downcase ).save
      end 
      errors_found ?
        flash[:error] = 'Error creating contacts.' :
        flash[:success] = 'Contacts created!'
        
      redirect_to contacts_path
    end
end
