if ENV['RACK_ENV'] == 'production'
  # We're running on Heroku
  DataMapper.setup(:default, ENV['DATABASE_URL'])
else
  # We're running locally
  DataMapper.setup(:default, "sqlite:online-arena.db")
end
