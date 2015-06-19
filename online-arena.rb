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
  erb(:main_page, :locals => {})
end

get("/class-list") do
  erb(:class_view, :locals => {})
end
#===================================#


#===========Admin Access============#
get("/admin") do
  erb(:admin, :locals => {})
end

get("/admin/modify-category") do
  erb(:a_category_modify, :locals => {})
end

get("/admin/modify-class") do
  erb(:a_class_modify, :locals => {})
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

post("/admin/class-add")do
  lesson_name = params["name"]
  lesson_space = params["space"]
  lesson_block = params["block"]
  @category_id = params[:category_id]
  lesson_category = params[:category_id]
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
#===================================#