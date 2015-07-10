# Online-Arena
Lowell High School's new Online Arena

## Running The Application

Make sure you're in the `online-arena` directory.  Once there, run the following two commands to configure your application correctly:

```
$ bundle install --without production
$ rake setup:dotenv
```

### On Cloud9

If you're using [Cloud9](http://c9.io), run the application with

```
$ ruby online-arena.rb -p $PORT -o $IP
```

### On Your Own Computer

If you're on your own computer, run the application with

```
$ ruby online-arena.rb
```

If everything runs successfully, you should be able to visit <http://localhost:4567> and see the web application.

------------------Instructions for admins----------------------
1) You must add a "category" for example "Math" or "Social Studies"
2) You must add a "subject" or the name of the class you are trying to add, for example "Geometry" or "AP Human Geography". Make sure there are no duplicates first.
3) You must add a "teacher" or the teacher of the class, for example, "Mr. Sinn" or "Mr. Martin"

4) Then you can go and add your class.



-------------------Notes----------------------
irb -r./environment

Seed.rb is for all the necessary things for our program to run as Jesse said.

lunch = Lunch.new(date: "2015-4-25")
lunch.add_menu_item_ids(["1", "2"])


user = User.find_by_email("kirby@kirby.com")
user.admin = true
user.save