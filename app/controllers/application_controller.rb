class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include SessionsHelper
  
  def redirect_to(options = {}, response_status = {})
    if request.xhr?
      render(:update) {|page| page.redirect_to(options)}
    else
      super(options, response_status)
    end
  end
  
  def admin_user
    @admin = User.find_by_email( Configuration.admin_email )
    redirect_to root_path unless current_user?(@admin)
  end
end
