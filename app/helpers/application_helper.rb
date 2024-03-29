module ApplicationHelper
  
  def listen_box
    listening = current_user.listening
    if current_user.default_notification_service &&
       !current_user.accounts.empty? &&
       !current_user.contacts.empty?
      check_box_tag( 'listening', 'listening', listening,
        {'data-href' => toggle_listening_user_path(current_user), :class => 'checkable' })
    end
  end
  
  def siteNav
    if user_signed_in?
      link("Accounts", root_path) + " " +
      link("Contacts", contacts_path)
    else
      #put logged_out links here.
    end
  end
  
  def link(label, path)
    if request.fullpath == path || label.downcase == params[:controller]
      link_to label, path, :class => 'selected'
    else
      link_to label, path
    end
  end
  
end
