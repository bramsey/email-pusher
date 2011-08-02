class Contact < ActiveRecord::Base
  attr_accessible :email, :active
  
  belongs_to :user
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :email, :presence => true,
                    :format => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false }
  
  validates :user_id, :presence => true
end
