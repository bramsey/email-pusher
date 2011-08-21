class InvitesController < ApplicationController
  
  before_filter :authenticate_user!,      :except => [:new, :create, :init]
  before_filter :admin_user, :only => [:index]
  
  def index
    @invites = Invite.all
    @approved = @invites.map { |invite| invite if invite.approved }
    @approved.compact!
    @unapproved = @invites - @approved
  end

  def new
    @invite = Invite.new
  end

  def create
    @invite = Invite.new(params[:invite])
    if @invite.save
      flash[:success] = "Thanks for your interest!"
      InviteMailer.thank_you_email( @invite ).deliver
    else
      flash[:error] = "There was an error submitting your email address, please check your entry and try again."
    end
    
    redirect_to root_path # possibly to a thank you page for analytics goal tracking.
  end

  def destroy
    Invite.find(params[:id]).destroy
    flash[:success] = "Invite destroyed."

    redirect_to invites_path
  end
  
  def approve
    @invite = Invite.find(params[:id])
    
    @invite.update_attribute(:approved, true)
    
    InviteMailer.approval_accepted_email( @invite ).deliver
    
    redirect_to invites_path
  end
  
  def disapprove
    @invite = Invite.find(params[:id])
    @invite.update_attribute(:approved, false)
    redirect_to invites_path
  end
  
  private
    
end
