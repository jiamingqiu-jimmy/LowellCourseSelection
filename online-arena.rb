require "sinatra"
require "data_mapper"

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
end

set(:sessions, true)
set(:session_secret, ENV["SESSION_SECRET"])

#===========Public Access===========#
get("/") do
  users = User.all
  erb(:main_page, :locals => {:users => users})
end

get("/class-view") do
  classes = Lesson.all
  erb(:class_view, :locals => {:classes => classes})
end

get("/class-select")do
  #--------------------Disabled until ready to launch(unless testing)---------------------#
#   utc_time = Time.parse(DateTime.now.to_s).utc
#   pacific_time = utc_time + Time.zone_offset("PDT")
#   puts utc_time
#   puts pacific_time
  
#   user = current_user
#   puts user.time
  
#   user_time = Time.parse(user.time.to_s)
  
#   if pacific_time < user_time
#     classes = Lesson.all
#     erb(:class_select, :locals => {:classes => classes})
#   else
#     redirect("/class-view")
#   end
# end

  classes = Lesson.all
  erb(:class_select, :locals => {:classes => classes})
end

get("/sign-up") do
  User.each do |user|
    user.status = :new
  end
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
  erb(:admin, :locals => {})
end

get("/admin/modify-registry") do
  registry = Registry.all
  erb(:a_registry_modify, :locals =>{:registry => registry})
end

get("/admin/modify-category") do
  categories = Category.all
  erb(:a_category_modify, :locals => {:categories => categories})
end

get("/admin/modify-class") do
  classes = Lesson.all
  erb(:a_class_modify, :locals => {:classes => classes})
end

get("/admin/modify-teacher") do
  teachers = Teacher.all
  erb(:a_teacher_modify, :locals => {:teachers => teachers})
end

get("/admin/set-user-time") do
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
end
#===================================#

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

post("/admin/category-delete/:category_id")do
  category = Category.get(params["category_id"])
  category.destroy
  
  if category.destroyed?
    redirect("/admin/modify-category")
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
  @category_id = params[:category_id]
  lesson_category = params[:category_id]
  lesson_teacher = params[:teacher_id]
  
  lesson = Lesson.new(
    name:         lesson_name,
    space:        lesson_space,
    block:        lesson_block
  )
  
  puts lesson_category
  p lesson_category
  p params[:category_id]
  p params["category_id"]
  p @category_id
  
  Category.get(lesson_category).lesson << lesson
  Teacher.get(lesson_teacher).lesson << lesson
  
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
  
  user.username.concat("_")
  user.username.concat(registry_name)
  
  Registry.get(registry_id).user << user
  
  if user.save
    sign_in!(user)

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
    redirect("/")
  else
    erb(:sign_in, :locals => { :user => user })
  end
end
#===================================# =>