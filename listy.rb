# A program for creating and working with To-Do lists. 

class ListyFly

  def initialize
    puts "What's your good name?"
    @name = gets.strip
    puts greet(@name)

    puts "1.) Make A To-Do List"
    puts "2.) Edit A To-Do List"

    # Get command to either make a list or edit one.
    while do_action = gets.strip
      case do_action
      when "1"
        make_list
      when "2"
        edit_list
      when "quit"
        puts "\nThank you for your time."
        abort
      else
        puts "I'm sorry, I don't understand. Please enter only from the above options."
      end
    end
  end

  # Find the time right now, and then greet the user accordingly.
  def greet(name)
    unless name.nil?
      case Time.now.hour
        when (6...12) 
          time_phase = "morning"
        when (12...16) 
          time_phase = "afternoon"
        when (16...20) 
          time_phase = "evening"
        when (20..24) || (1...6) 
          time_phase = "night"
      end
      return "\nGood #{time_phase}, #{name}! What would you like me to do?\n"
    end
  end

  # Initiate a new to-do list.
  def make_list
    puts "Okay, what would you like to name the list?"
    @file_name_topic = gets.strip
    file = File.new("#{@file_name_topic.capitalize}.txt", 'w')
    write_stuff_to(file)
    file.close
    puts "\n#{@name}, your to-do list has been prepared."
    puts "\nEnter 1 to make a to-do list. Enter 2 to edit one."
    puts "Or enter 'quit' to finish your session."
  end

  # Get input for the file.
  def get_file_input_for(file_content)
    puts "Enter the items below. You can finish entering by typing in 'END'."
    # Get the main tasks
    while task = gets.strip
      return file_content if task == "END" || task == "end"
      main_task = {"#{task}" => []}
      file_content.push(main_task)
      puts "Would you like to add subtasks? Please answer in 'yes' or 'no'."
      # Do you want any subtasks?
      while subtask_decision = gets.strip
        case subtask_decision
        when "yes"
          puts "Okay, enter the subtasks below. You can finish entering by typing in 'END'."
          # Get the subtasks
          while subtask = gets.strip
            break if subtask == "END" || subtask == "end"
            main_task["#{task}"].push(subtask)
          end
          puts "Ok, enter next item. You can finish entering by typing in 'END'."
          break
        when "no"
          puts "Ok, enter next item. You can finish entering by typing in 'END'."
          break
        else
          puts "Please answer in 'yes' or 'no'."
          puts "Would you like to add subtasks?"
        end
      end
    end
  end

  # Write whatever input you've gotten to the file.
  def write_stuff_to(file)
    @new_file_content = []
    @num_of_tasks = 0
    @num_of_subtasks = 0

    file << "#{"//"*15} #{@file_name_topic.upcase} #{"//"*15}\n"
    @new_file_content = get_file_input_for(@new_file_content)
    @new_file_content.each_with_index do |hash, index|
      @num_of_tasks = index + 1
      task = hash.keys[0]
      file << "\n#{@num_of_tasks}.) " + task + " [_]\n"
      unless hash[task].empty?
        hash[task].each_with_index do |subtask, index|
          @num_of_subtasks += 1
          file << "\t #{index + 1} -> " + subtask + " |_|\n"
        end
      end
    end
    file << "\n#{"-"*50}"
    file << "\n ** Main Tasks: #{@num_of_tasks} total, 0 finished, #{@num_of_tasks} left."
    file << "\n ** Sub Tasks: #{@num_of_subtasks} total, 0 finished, #{@num_of_subtasks} left."
    file << "\n#{"-"*50}"
  end

  # Load a list to edit it.
  def edit_list
    puts "Okay, which to-do list would you like to edit?"
    file_edit_name = gets.strip
    @edit_file = "#{file_edit_name}.txt"
    @edit_file_content = parse_file(@edit_file)
    puts "Your file has been loaded. What would you like me to do?\n\n"
    @edit_options = %q{
    1.) List the number of tasks left.
    2.) List each task.
    3.) List completed tasks.
    4.) List incomplete tasks.
    5.) Mark a task complete.
    }
    puts @edit_options
    while what_to_edit_options = gets.strip
      list_action(what_to_edit_options)
    end
  end

  # Initiate other options after loading the file.
  def list_action(number)
    case number
    when "1"
      list_num_tasks_left
    when "2"
      list_each_task
    when "3"
      list_completed_tasks
    when "4"
      list_incomplete_tasks
    when "5"
      mark_task
    when "quit"
      puts "\nThank you for your time."
      abort
    end
    puts "\n\nEnter 'quit' to finish session. Or use any other options."
    puts @edit_options
  end

  # Takes in an array filled with each element corresponding to 
  # each line in a file. Restructures the line-based array to an
  # array with hashes as main tasks and sub-tasks as children of
  # the hash.

  # How the output data_structure looks like:
  # data_structure = [
  #   { "Grocery" => ["Milk", "Potatoes", "Ketchup"] },
  #   { "Stationary" => ["Pens", "Pencils"] },
  #   { "Greeting Cards" => [] }
  # ]
  def parse_lines_to_data_structure(array_lines, data_structure)
    array_lines.each_with_index do |line, index|
      if line =~ /\.\) /
        main_task = {"#{line.strip}" => []}
        data_structure.push(main_task)
        n = 1
        while array_lines[index + n] =~ / -> /
          main_task["#{line.strip}"].push(array_lines[index + n].strip)
          n += 1
        end
      end
    end
    return data_structure
  end

  # Takes in a file and parses it to a more flexible data structure.
  def parse_file(file)
    @filelines = File.readlines(file)
    @edit_file_content = []
    parse_lines_to_data_structure(@filelines, @edit_file_content)
  end

  # Lists the number of tasks left in a to-do list.
  def list_num_tasks_left
    num_of_tasks_left = 0
    num_of_subtasks_left = 0
    @edit_file_content.each do |hash|
      # if task is incomplete
      if hash.keys[0] =~ /\[_\]/
        num_of_tasks_left += 1
        # does the task have subtasks?
        unless hash[hash.keys[0]].empty?
          hash[hash.keys[0]].each do |subtask|
            # if subtask is incomplete
            if subtask =~ /\|_\|/
              num_of_subtasks_left += 1
            end
          end
        end
      end
    end
    puts "#{"-"*30}\n" + "#{num_of_tasks_left} main task(s) left."
    puts "#{num_of_subtasks_left} subtask(s) left." + "\n#{"-"*30}"
  end

  # List each task in the list.
  def list_each_task
    @edit_file_content.each do |hash|
      puts hash.keys[0]
      unless hash[hash.keys[0]].empty?
        hash[hash.keys[0]].each do |subtask|
          puts "\t" + subtask
        end
      end
    end
  end

  # Returns an array with all completed tasks.
  def get_completed_tasks
    @completed_tasks = []
    @no_of_completed_main_tasks = 0
    @no_of_completed_sub_tasks = 0
    @edit_file_content.each do |hash|
      # Push if it is completed ({x}) and make sure that it is a main task.
      if hash.keys[0] =~ /\{x\}/ && hash.keys[0] =~ /\.\) /
        @completed_tasks.push(hash.keys[0])
        @no_of_completed_main_tasks += 1
      end
      unless hash[hash.keys[0]].empty?
        hash[hash.keys[0]].each do |subtask|
          # Push if it is completed ({x}) and make sure that it is a subtask.
          if subtask =~ /\{x\}/ && subtask =~ / -> /
            @completed_tasks.push("\t#{subtask}")
            @no_of_completed_sub_tasks += 1
          end
        end
      end
    end
    return @completed_tasks
  end

  # Outputs all completed tasks as strings.
  def list_completed_tasks
    get_completed_tasks
    unless @completed_tasks.empty?
      puts @completed_tasks
    else
      puts "You have no completed tasks."
    end
  end

  # Returns an array with all incomplete tasks.
  def get_incomplete_tasks
    @incomplete_tasks = []
    @no_of_incomplete_main_tasks = 0
    @no_of_incomplete_sub_tasks = 0
    @edit_file_content.each do |hash|
      # Push if it is incomplete
      # [_] corresponds to a main task.
      # |_| corresponds to a subtask
      if hash.keys[0] =~ /\[_\]/
        @incomplete_tasks.push(hash.keys[0])
        @no_of_incomplete_main_tasks += 1
      end 
      unless hash[hash.keys[0]].empty?
        hash[hash.keys[0]].each do |subtask|
          # Push if it is incomplete
          if subtask =~ /\|_\|/
            @incomplete_tasks.push("\t#{subtask}")
            @no_of_incomplete_sub_tasks += 1
          end
        end
      end
    end
    return @incomplete_tasks
  end

  # Outputs all incomplete tasks as strings.
  def list_incomplete_tasks
    get_incomplete_tasks
    unless @incomplete_tasks.empty?
      puts @incomplete_tasks
    else
      puts "All your tasks have been completed."
    end
  end

  # Mechanism for marking off tasks as complete.
  def mark_task
    # Get both incomplete and complete tasks so as to get data on 
    # number of subtasks and number of main tasks, both complete 
    # and incomplete.
    get_completed_tasks
    get_incomplete_tasks
    unless @incomplete_tasks.empty? # Are all tasks completed?
      @filelines.each_with_index do |task, index|
        # If task is incomplete
        # [_] corresponds to a main task
        # |_| corresponds to a subtask
        if task =~ /\[_\]|\|_\|/
          puts "(#{index}) " + task 
        end
      end
      puts "\nEnter the number in parentheses corresponding to the task you wish to mark as completed:"
      while task_number = gets.strip
        break if task_number == "quit"
        # If the line is a main task
        if @filelines[task_number.to_i] =~ /\[_\]/
          @filelines[task_number.to_i].gsub!(/\[_\]/, "{x} DONE!")
          @no_of_completed_main_tasks += 1
          @no_of_incomplete_main_tasks -= 1
        # If the line is a sub task
        elsif @filelines[task_number.to_i] =~ /\|_\|/
          @filelines[task_number.to_i].gsub!(/\|_\|/, "{x} DONE!")
          @no_of_completed_sub_tasks += 1
          @no_of_incomplete_sub_tasks -= 1
        end
        puts "You can enter quit to finish or keep on marking off."
      end

      # Variables to aid writing meta data into file.
      @num_of_tasks = @no_of_completed_main_tasks + @no_of_incomplete_main_tasks
      @num_of_subtasks = @no_of_completed_sub_tasks + @no_of_incomplete_sub_tasks

      # Prepare a new file to override the old file. 
      file = File.new(@edit_file, 'w')
      # 4 times remove the last line in file.
      # Basically, remove the previous meta data on file.
      4.times { @filelines.pop }
      # Push the new meta data into file.
      @filelines.push("#{"-"*50}")
      @filelines.push(" ** Main Tasks: #{@num_of_tasks} total, #{@no_of_completed_main_tasks} finished, #{@no_of_incomplete_main_tasks} left.")
      @filelines.push(" ** Sub Tasks: #{@num_of_subtasks} total, #{@no_of_completed_sub_tasks} finished, #{@no_of_incomplete_sub_tasks} left.")
      @filelines.push("#{"-"*50}")
      file.puts @filelines
      file.close
      # Parse the file again
      @edit_file_content = parse_file(file)
    else
      "All your tasks have been completed."
    end
  end
end

ListyFly.new
