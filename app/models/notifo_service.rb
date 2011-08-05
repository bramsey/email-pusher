class NotifoService < NotificationService
  require 'notifo'
  
  def notify( sender, subject )
    # Overload NotificationService notify method to trigger Notifo notification.
    
    #notifo = Notifo.new("billiamram","notifo_key")
    notifo = Notifo.new("vybly", "notifo_key")
    notifo.post(username, subject, "New message from #{sender}!")
    
  end
  
  def description
    "Send notification to Notifo account: #{username}"
  end
end
