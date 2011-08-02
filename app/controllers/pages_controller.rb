class PagesController < ApplicationController
  def home
    @accounts = current_user.accounts if user_signed_in?
    
  end

end
