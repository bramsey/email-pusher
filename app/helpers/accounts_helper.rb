module AccountsHelper
  
  def activate_box_for( account )
    active = account.active
    check_box_tag( "active#{account.id}", "active#{account.id}", active,
      {'data-href' => toggle_active_account_path(account), :class => 'checkable' })
   end

  def select_box_for( account )
    select_tag( "notification_service_#{account.id}", 
                options_from_collection_for_select(account.user.notification_services, 
                                                   :id, 
                                                   :description, account.notification_service_id),
                :onchange => remote_function(
                  :url => update_service_account_path(account),
                  :with => "'service_id=' + this.value"
                ))
  end
  
  def current_user?(user)
    user == current_user
  end
end
