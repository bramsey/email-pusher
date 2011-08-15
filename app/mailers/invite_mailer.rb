class InviteMailer < ActionMailer::Base
  default :from => "bill@vybit.com"
  
  def thank_you_email( invite )
    #@invite = invite
    mail(:to => invite.email,
       :subject => "Thanks for your interest in the Vybit Email Notifier!")
  end
end
