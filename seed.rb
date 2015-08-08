require_relative "environment"

DEFAULT_REGISTRIES = [
  {
    name: "1706",
  },
  {
    name: "1707",
  }
]

DEFAULT_REGISTRIES.each do |registry_data|
  puts "Creating #{registry_data[:name]}..."
  Registry.create(registry_data)
end

DEFAULT_USERS = [
  {
    username: "Admin",
    email: "admin@gmail.com",
    password: "123456",
    password_confirmation: "123456",
    admin: true,
    registry_id: "1"
  }
]

DEFAULT_USERS.each do |user_data|
  puts "Creating #{user_data[:name]}..."
  User.create(user_data)
end