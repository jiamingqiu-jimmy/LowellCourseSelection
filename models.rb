    class User
      include DataMapper::Resource
        
      property :id,           Serial
    
      property :username,     String,
        :required => true,
        :unique   => true
        
    	property :email,        String,
      	:format   => :email_address,
      	:required => true,
      	:unique   => true,
      	:messages => {
      		:format => "You must enter a valid email address."
    	}
      
      property :password,     BCryptHash, 
        :required => true
    
      validates_confirmation_of :password
      
    	attr_accessor :password_confirmation
    	validates_length_of :password_confirmation, :min => 6, :if => lambda { |t| t.status == :new }
    	
    	
      property :status,       Enum[ :new, :change], default: :new
      
      # validates_presence_of :password, :if => lambda { |t| t.status == :new }
      # validates_presence_of :username, :if => lambda { |t| t.status == :new }
      # validates_presence_of :email, :if => lambda { |t| t.status == :new }

    	
    	property :time,         DateTime
    	
    	def valid_password?(unhashed_password)
    	  self.password == unhashed_password
    	end
    	
    	def self.find_by_email(email)
    		self.first(:email => email)
    	end
    	
    	
    	has n, :user_lessons
    	has n, :lessons, through: :user_lessons
      
      has n, :user_subjects
      has n, :subjects, through: :user_subjects
      
      belongs_to :registry
    end

class UserLesson
  include DataMapper::Resource
  
  property :id,         Serial
  
  belongs_to    :user
  belongs_to    :lesson
end

class UserSubject
  include DataMapper::Resource
  
  property :id,         Serial
  
  belongs_to   :user
  belongs_to   :subject
end

class Lesson
  include DataMapper::Resource
  
  property :id,           Serial
  property :space,        Integer
  property :block,        Integer
  
  has n, :user_lessons
  has n, :users, through: :user_lessons
  
  belongs_to :subject
  belongs_to :category
  belongs_to :teacher
end

class Subject
  include DataMapper::Resource
  
  property :id,           Serial
  property :name,         String, :unique => true
  
  has n, :lesson, constraint: :destroy
  
  has n, :user_subjects
  has n, :users, through: :user_subjects
  
end

class Category
  include DataMapper::Resource
  
  property :id,           Serial
  property :name,         String, :unique => true
  
  has n, :lesson, constraint: :destroy
end

class Teacher
  include DataMapper::Resource
  
  property :id,           Serial
  property :name,         String, :unique => true
  
  has n, :lesson, constraint: :destroy
end

class Registry
  include DataMapper::Resource
  
  property :id,           Serial
  property :name,         Integer

  has n, :user
end

DataMapper.finalize
DataMapper.auto_upgrade!