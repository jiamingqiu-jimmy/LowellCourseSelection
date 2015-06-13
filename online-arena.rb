require "sinatra"
require "data_mapper"

require "./environment"

helpers do
  # def current_user
  #   # Return nil if no user is logged in
  #   return nil unless session.key?(:user_id)
    
  #   # If @current_user is undefined, define it by
  #   # fetching it from the database.
  #   @current_user ||= User.get(session[:user_id])
  # end
  
  # def user_signed_in?
  # # A user is signed in if the current_user method
  #   # returns something other than nil
  #   !current_user.nil?
  # end
      
  # def sign_in!(user)
  #   session[:user_id] = user.id
    
  #   @current_user = user
  # end
      
  # def sign_out!
  #   @current_user = nil
    
  #   session.delete(:user_id)
  # end
end

#===========Public Access===========#
get("/") do
  erb(:main_page, :locals => {})
end

# get("/class-list") do
#   erb(:class_view, :locals => {})
# end
# #===================================#


# #===========Admin Access============#
# get("/admin") do
#   erb(:admin, :locals => {})
# end

# get("/admin/modify-category") do
#   erb(:category_modify, :locals => {})
# end

# get("/admin/modify-class") do
#   erb(:class_modify, :locals => {})
# end
# #===================================#

# #==========Changes==================#
# post("/admin/category-add")do
#   category_name = params["name"]
  
#   category = Category.create(
#     name:      category_name
#   )
  
#   if category.saved?
#     redirect("/admin/modify-category")
#   else
# 		erb(:error)
#   end
# end

# post("/admin/class-add")do
#   class_name = params["name"]
#   class_teacher = params["teacher"]
#   class_spots = params["spots"]
  
#   new_class = Class.create(
#     name:         class_name,
#     teacher:      class_teacher,
#     spots:        class_spots,
#   )
  
#   if new_class.saved?
#     redirect("/admin/modify-class")
#   else
#     erb(:error)
#   end
# end
# #===================================#