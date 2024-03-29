class NotifoService < NotificationService
  require 'notifo'
  require 'json'
  
  before_save :verify_notifo
  
  def notify( sender, subject, recipient )
    # Overload NotificationService notify method to trigger Notifo notification.
    
    notifo = Notifo.new( Configuration.notifo_service_user, 
                         Configuration.notifo_service_key )
    notifo.post( username, subject, "New email from #{sender} to #{recipient}!" )
  end
  
  def description
    "Send notification to Notifo account: #{username}"
  end
  
  private
  
    def verify_notifo
      notifo = Notifo.new(Configuration.notifo_service_user, 
                          Configuration.notifo_service_key)
      response = JSON( notifo.subscribe_user( username ) )
      
      if response
        unless response['status'] == "success"
          # Case allows checking of new error codes if necessary.
          case response['response_code']
          when 1105
            errors.add( :username, 
              'No such user found. Please check the id or register if needed.' )
          when 1102
            errors.add( :username, 'Not allowed to send to user.' )
          when 1106
            errors.add( :username, 'Not allowed to subscribe user.' )
          else
            errors.add( :username, 'Unable to verify Notifo account.' )
          end
          return false
        end
        logger.info response
      else
        errors.add( :username, 'Unable to connect to Notifo.' )
        return false
      end
    end
end
