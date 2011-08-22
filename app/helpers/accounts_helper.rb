module AccountsHelper
  
  def activate_account_box_for( account )
    active = account.active
    check_box_tag( "active#{account.id}", "active#{account.id}", active,
      {'data-href' => toggle_active_account_path(account), :class => 'checkable' })
  end
  
  def current_user?(user)
    user == current_user
  end
end
