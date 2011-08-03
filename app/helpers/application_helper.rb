module ApplicationHelper
  
  def listen_box
    listening = current_user.listening
    check_box_tag( "listening", "listening", listening,
      {'data-href' => toggle_listening_user_path(current_user), :class => 'checkable' })
  end
  
  def siteNav
    if user_signed_in?
      link("Accounts", root_path) + " - " +
      link("Contacts", contacts_path)
    else
      #put logged_out links here.
      #link("About", about_path) +
      #link("Contact", contact_path)
    end
  end
  
  def link(label, path)
    if request.request_uri == path
      link_to label, path, :class => "selected"
    else
      link_to label, path
    end
  end
end
