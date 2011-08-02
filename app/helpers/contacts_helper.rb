module ContactsHelper
  
  def activate_box_for( contact )
    active = contact.active
    check_box_tag( "active#{contact.id}", "active#{contact.id}", active,
      {'data-href' => toggle_active_contact_path(contact), :class => 'checkable' })
  end
end
