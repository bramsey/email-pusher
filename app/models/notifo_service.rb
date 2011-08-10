class NotifoService < NotificationService
  require 'notifo'
  
  def notify( sender, subject, recipient )
    # Overload NotificationService notify method to trigger Notifo notification.
    
    notifo = Notifo.new(Configuration.notifo_service_user, Configuration.notifo_service_key)
    notifo.post(username, subject, "New email from #{sender} to #{recipient}!")
    
  end
  
  def description
    "Send notification to Notifo account: #{username}"
  end
end
