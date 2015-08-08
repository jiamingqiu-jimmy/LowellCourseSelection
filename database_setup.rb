if ENV['RACK_ENV'] == 'production'
  # We're running on Heroku
  DataMapper.setup(:default, ENV['DATABASE_URL'])
else
  # We're running locally
  DataMapper.setup(:default, "sqlite:online-arena.db")
end

# configure :development do
#   DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/online-arena.db")
# end

# configure :production do
#   DataMapper.setup(:default, ENV['DATABASE_URL'])
# end

