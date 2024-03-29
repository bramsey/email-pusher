class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def open_id
    @user = User.find_for_open_id(env['omniauth.auth'], current_user)
    if @user.persisted?
      if @user.approved?
        sign_in_and_redirect( @user, :event => :authentication )
      else
        flash[:notice] = 'Your invite request is currently pending.'
        redirect_to( root_path )
      end
    else
      session['devise.open:id_data'] = env['openid.ext1']
      redirect_to new_user_registration_url
    end
  end

end