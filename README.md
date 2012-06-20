# ListyFly

ListyFly is a command line based application for creating and editing to-do lists.
It includes task-nesting, task meta information and many other useful features. 

## Usage ##

First, download the file and change your current working directory to the newly downloaded folder. 
Then, load the listy.rb file and initiate it.
```ruby
$ irb
irb(main):001:0> require "./listy.rb"
=> true
irb(main):002:0> ListyFly.new
```
You will be greeted by a message:
```
What's your good name?
```
Enter in your name (or anything else, if that's how you roll). Then:
```
Good morning, name! What would you like me to do?
1.) Make A To-Do List
2.) Load A To-Do List
```
Again, you will be prompted to reply, and you can choose '1' or '2' as shown. 

Rest should be fairly straightforward. Have fun, and be productive! 