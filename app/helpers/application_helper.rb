module ApplicationHelper
  
  def listen_box
    listening = current_user.listening
    check_box_tag( "listening", "listening", listening,
      {'data-href' => toggle_listening_user_path(current_user), :class => 'checkable' })
  end
end
