class Contact < ActiveRecord::Base
  attr_accessible :email, :active
  
  belongs_to :user
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :email, :presence => true,
                    :format => { :with => email_regex }
  
  validates :email, 
              :uniqueness => {:scope => :user_id, 
                                        :message => "You already have this contact."}
  
  validates :user_id, :presence => true
end
