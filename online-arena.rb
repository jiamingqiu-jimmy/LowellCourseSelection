require "sinatra"
require "data_mapper"
require 'json'

require "./environment"

helpers do
  def current_user
    # Return nil if no user is logged in
    return nil unless session.key?(:user_id)
    
    # If @current_user is undefined, define it by
    # fetching it from the database.
    @current_user ||= User.get(session[:user_id])
  end
  
  def user_signed_in?
  # A user is signed in if the current_user method
    # returns something other than nil
    !current_user.nil?
  end
  
  def sign_in!(user)
    session[:user_id] = user.id
    
    @current_user = user
  end

  def sign_out!
    @current_user = nil
    
    session.delete(:user_id)
  end
  
  def is_user_admin?
    user = @current_user
    user.admin
  end
end

set(:sessions, true)
set(:session_secret, ENV["SESSION_SECRET"])

#===========Public Access===========#
get("/") do
  users = User.all
  erb(:main_page, :locals => {:users => users})
end

get("/class-view") do
  if user_signed_in?
    categories = Category.all(order: :name.asc)
    erb(:class_view, :locals => {:categories => categories})
  else
    redirect("/error/user")
  end
end

get("/class-select") do
  if user_signed_in?
    categories = Category.all(order: :name.asc)
    user = current_user
    a = user.subjects
    user_subjects = JSON.parse(a.to_json)
    puts user_subjects
    erb(:class_select, :locals => {:categories => categories, :user => user, :user_subjects => user_subjects})
  else
    redirect("/error/user")
  end
  
end

get("/teacher-select")do
  if user_signed_in?
    #--------------------Disabled until ready to launch(unless testing)---------------------#
    #   utc_time = Time.parse(DateTime.now.to_s).utc
    #   pacific_time = utc_time + Time.zone_offset("PDT")
    #   puts utc_time
    #   puts pacific_time
      
    #   user = current_user
    #   puts user.time
      
    #   user_time = Time.parse(user.time.to_s)
      
    #   if pacific_time < user_time
    user = current_user
    erb(:teacher_select, :locals => {:user => user})
    #   else
    #     redirect("/class-view")
    #   end
  else
    redirect("/error/user")
  end
  
end

get("/sign-up") do
  user = User.new
  erb(:sign_up, :locals => {:user => user})
end

get("/sign-in") do
  user = User.new
  erb(:sign_in, :locals => {:user => user})
end

get("/sign_out") do
  sign_out!
  redirect("/")
end
#===================================#


#===========Admin Access============#
get("/admin") do
  if user_signed_in?
    if is_user_admin?
      erb(:admin, :locals => {})
    else
      redirect("/error/admin")
    end
  else
    redirect("/error/user")
  end
end

get("/admin/modify-registry") do
  # if user_signed_in?
  #   if is_user_admin?
      registry = Registry.all
      erb(:a_registry_modify, :locals =>{:registry => registry})
    # else
      # redirect("/error/admin")
  #   end
  # else
    # redirect("/error/user")
  # end
end

get("/admin/modify-category") do
  if user_signed_in?
    if is_user_admin?
      categories = Category.all
      erb(:a_category_modify, :locals => {:categories => categories})
    else
      redirect("/error/admin")
    end
  else
    redirect("/error/user")
  end
end

get("/admin/modify-subject") do
  if user_signed_in?
    if is_user_admin?
      subjects = Subject.all
      erb(:a_subject_modify, :locals => {:subjects => subjects})
    else
      redirect("/error/admin")
    end
  else
    redirect("/error/user")
  end
end

get("/admin/modify-class") do
  if user_signed_in?
    if is_user_admin?
      categories = Category.all
      erb(:a_class_modify, :locals => {:categories => categories})
    else
      redirect("/error/admin")
    end
  else
    redirect("/error/user")
  end
end

get("/admin/modify-teacher") do
  if user_signed_in?
    if is_user_admin?
      teachers = Teacher.all
      erb(:a_teacher_modify, :locals => {:teachers => teachers})
    else
      redirect("/error/admin")
    end
  else
    redirect("/error/user")
  end
end

get("/admin/set-class-select") do
  if user_signed_in?
    if is_user_admin?
      User.each do |user|
        user.status = :change
        puts "It worked"
        if user.save
          puts "saved"
        else
          user.errors.each do |error|
            puts error
          end
        end
      end
      erb(:a_user_time, :locals => {})
    else
      redirect("/error/admin")
    end
  else
    redirect("/error/user")
  end
end

get("/admin/view-users") do
  if user_signed_in?
    if is_user_admin?
      users = User.all
      erb(:a_user_view, :locals => {:users => users})
    else
      redirect("/error/admin")
    end
  else
    redirect("/error/user")
  end
end
#===================================#

#==========Errors===================#
get("/error/user") do
  erb(:error_user, :locals => {})  
end

get("/error/admin") do
  erb(:error_admin, :locals => {})
end
#==========Changes==================#
post("/admin/category-add")do
  category_name = params["name"]
  
  category = Category.new(
    name:      category_name
  )
  
  if category.save
    redirect("/admin/modify-category")
  else
		erb(:error)
  end
end

post("/admin/category-delete")do
  category = Category.get(params["category_id"])
  category.destroy
  
  if category.destroyed?
    redirect("/admin/modify-category")
  else
    erb(:error)
  end
end

post("/admin/subject-add")do
  subject_name = params["name"]
  subject_category = params[:category_id]
  
  puts subject_name
  p puts params[:category_id]
  
  subject = Subject.new(
    name:      subject_name
  )
  
  Category.get(subject_category).subjects << subject
  
  if subject.save
    redirect("/admin/modify-subject")
  else
		erb(:error)
  end
end

post("/admin/teacher-add")do
  teacher_name = params["name"]
  
  teacher = Teacher.new(
    name:     teacher_name
  )
  
  if teacher.save
    redirect("/admin/modify-teacher")
  else
    erb(:error)
  end
end

post("/admin/teacher-delete/:teacher_id")do
  teacher = Teacher.get(params["teacher_id"])
  teacher.destroy
  
  if teacher.destroyed?
    redirect("/admin/modify-teacher")
  else
    teacher.errors.each do |error|
      p #############
      p error
    end
    erb(:error)
  end
end


post("/admin/class-add")do
  lesson_name = params["name"]
  lesson_space = params["space"]
  lesson_block = params["block"]
  lesson_teacher = params[:teacher_id]
  lesson_subject = params[:subject_id]
  
  lesson = Lesson.new(
    space:        lesson_space,
    block:        lesson_block
  )
  
  Teacher.get(lesson_teacher).lessons << lesson
  Subject.get(lesson_subject).lessons << lesson
  
  if lesson.save
    redirect("/admin/modify-class")
  else
		puts "something went horribly wrong"
		lesson.errors.each do |error|
			p error
		end
    erb(:error)
  end
end

post("/admin/class-delete/:lesson_id")do
  lesson = Lesson.get(params["lesson_id"])
  lesson.destroy
  
  if lesson.destroyed?
    redirect("/admin/modify-class")
  else
    erb(:error)
  end
end

post("/admin/registry-add")do
  registry_name = params["name"]
  
  registry = Registry.new(
    name:      registry_name
  )
  
  if registry.save
    redirect("/admin/modify-registry")
  else
		erb(:error)
  end
end

post("/admin/registry-delete/:registry_id")do
  registry = Registry.get(params["registry_id"])
  registry.destroy
  
  if registry.destroyed?
    redirect("/admin/modify-registry")
  else
    erb(:error)
  end
end

post("/admin/set-time") do
  p puts params["registry_id"]
  puts params["date"]
  puts params["hour"]
  puts params["minute"]
  
  registry = params["registry_id"]
  puts registry
  time = params["hour"]
  time.concat(":")
  time.concat(params["minute"])
  puts time

  date = params["date"]
  puts date
  
  datetime = date
  datetime.concat(" ")
  datetime.concat(time)
  puts datetime
  
  access_time = Time.parse(datetime)
  puts access_time
  
  registry.each do |registry_id|
    puts registry_id
    Registry.get(registry_id).user.each do |user|
      user.time = access_time
      puts user.time
      if user.save
        redirect("/admin/set-user-time")
      else
        puts "something went horribly wrong"
		    user.errors.each do |error|
		    	p error
	     	  erb(:error)
        end
      end
    end
  end
end

post("/sign-up") do 
  p puts params["registry_id"]
  registry_id = params["registry_id"].to_i
  p puts registry_id
  registry_name = Registry.get(params["registry_id"]).name.to_s
  p puts registry_name
  user = User.new(params[:user])
  
  # user.username.concat("_")
  # user.username.concat(registry_name)
  
  Registry.get(registry_id).users << user
  
  if user.save
    sign_in!(user)
    user.validation_status = :change
    user.save
    redirect("/")
  else
    erb(:sign_up, :locals => { :user => user })
  end
end

post("/sign-in") do
  user = User.find_by_email(params[:email])
  
  if user && user.valid_password?(params[:password])
    sign_in!(user)
    puts "Worked?"
    user.validation_status = :change
    user.save
    redirect("/")
  else
    erb(:sign_in, :locals => { :user => user })
  end
end

post("/class-select") do
  subject_names = params["schedule"]
  u = current_user
  user = User.get(u.id)
  # p puts subject_names
  subject_names.each do |subject_name|
    # puts subject_name
    if (!Subject.first(:name => subject_name).nil?)
      # puts "Hi"
      user.subjects << Subject.first(:name => subject_name)
    end
  end

  # user.subjects << Subject.get(subject_id)
  
  if user.save
    redirect("/class-select")
  else
    user.errors.each do |error|
      p error
    end
    erb(:error)
  end
end

post("/teacher-select") do
  p puts params["lesson_id"]
  lesson_id = params["lesson_id"]
  a = current_user
  user = User.get(a.id)
  user.lessons << Lesson.get(lesson_id)
  if user.save
    p puts user
    redirect("/teacher-select")
  else
    user.errors.each do |error|
    	p error
   	  erb(:error)
    end
  end
end

post("/add-student") do
  id = params[:lesson_id]
  name = params[:lesson_name]
  puts id
  puts name
  
  lesson = Lesson.get(id)
  if (lesson.space >= 1)
    puts lesson.space
    lesson.space = lesson.space - 1
    lesson.save
    puts lesson.space
    lesson.space = lesson.space + 1
    lesson.save
  else
    erb(:error)
  end
end
#===================================# =>