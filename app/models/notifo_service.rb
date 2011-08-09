class NotifoService < NotificationService
  require 'notifo'
  
  def notify( sender, subject )
    # Overload NotificationService notify method to trigger Notifo notification.
    
    #notifo = Notifo.new("billiamram","notifo_key")
    notifo = Notifo.new("vybit", "fa9c05b25c34c8d5c364c8c9b400586ce5c60e4f")
    notifo.post(username, subject, "New email from #{sender}!")
    
  end
  
  def description
    "Send notification to Notifo account: #{username}"
  end
end
