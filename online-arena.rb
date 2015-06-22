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

#===========Public Access===========#
get("/") do
  users = User.all
  erb(:main_page, :locals => {:users => users})
end

get("/class-list") do
  erb(:class_view, :locals => {})
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
  erb(:admin, :locals => {})
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

#Having a similar name for a POST and a GET might cause errors

post("/sign-up") do 
  registry = params["registry"]
  user = User.new(params[:user])
  
  user.username.concat("_")
  user.username.concat(registry)
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
    redirect("/")
  else
    erb(:sessions_new, :locals => { :user => user })
  end
end
#===================================#