require "data_mapper"

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
	validates_length_of :password_confirmation, :min => 6, :if => lambda { |t| t.validation_status == :new }
	
  property :validation_status,       Enum[ :new, :change], default: :new
  
  property :selection_status,        Enum[ :none, :class, :teacher], default: :none
  
  # validates_presence_of :password, :if => lambda { |t| t.status == :new }
  # validates_presence_of :username, :if => lambda { |t| t.status == :new }
  # validates_presence_of :email, :if => lambda { |t| t.status == :new }

  property :admin,        Boolean, default: false
	property :class_time,   DateTime
	property :teacher_time, DateTime
	
	def valid_password?(unhashed_password)
	  self.password == unhashed_password
	end
	
	def self.find_by_email(email)
		self.first(:email => email)
	end
	
  has n, :user_subjects
  has n, :subjects, through: :user_subjects
  
  has n, :user_lessons
  has n, :lessons, through: :user_lessons
  
  belongs_to :registry
end


class UserSubject
  include DataMapper::Resource
  
  property :id,         Serial
  
  belongs_to   :user
  belongs_to   :subject
end

class Subject
  include DataMapper::Resource
  
  property :id,           Serial
  property :name,         String
  
  validates_uniqueness_of :name
  
  has n, :lessons, constraint: :destroy
  belongs_to :category
  
  has n, :user_subjects, constraint: :destroy
  has n, :users, through: :user_subjects
  
end

class UserLesson
  include DataMapper::Resource
  
  property :id,         Serial
  
  belongs_to :user
  belongs_to :lesson
end

class Lesson
  include DataMapper::Resource
  
  property :id,           Serial
  property :space,        Integer
  property :block,        Integer
  
  has n, :user_lessons, constraint: :destroy
  has n, :users, through: :user_lessons
  
  belongs_to :subject
  belongs_to :teacher
end

class Category
  include DataMapper::Resource
  
  property :id,           Serial
  property :name,         String, :unique => true
  
  has n, :subjects, constraint: :destroy
end

class Teacher
  include DataMapper::Resource
  
  property :id,           Serial
  property :name,         String, :unique => true
  
  has n, :lessons, constraint: :destroy
end

class Registry
  include DataMapper::Resource
  
  property :id,           Serial
  property :name,         Integer

  has n, :users, constraint: :destroy
end

DataMapper.finalize()
DataMapper.auto_upgrade!()