class PagesController < ApplicationController
  def home
    @accounts = current_user.accounts
    
  end

end
