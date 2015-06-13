class User
  include DataMapper::Resource
    
  property :id,           Serial
    
  property :username,     String,
    :required => true,
    :unique   => true
    
  property :password,     BCryptHash, :required => true
  validates_confirmation_of :password
  
	attr_accessor :password_confirmation
	validates_length_of :password_confirmation, :min => 6
	
	def valid_password?(unhashed_password)
	  self.password == unhashed_password
	end
	
	property :admin,       Boolean, default: false
	
	has n, :user_categories
	has n, :categories, through: :user_categories
end

class UserCategory
  include DataMapper::Resource
  
  property :id,         Serial
  
  belongs_to    :user
  belongs_to    :category
end

class Category
  include DataMapper::Resource
  
  property :id,           Serial
  property :title,         String
  
  has n, :class
  
  has n, :user_categories
  has n, :users, through: :user_categories
end


class Class
  include DataMapper::Resource
  
  property :id,           Serial
  property :name,         String
  property :teacher,      String
  property :spots,        Integer
  
  belongs_to :category
end


DataMapper.finalize
Datamapper.auto_upgrade!