# A program for creating and working with advanced To-Do lists. 

class ListyFly

  def initialize
    puts "What's your good name?"
    @name = gets.strip
    puts greet(@name)

    puts "1.) Make A To-Do List"
    puts "2.) Edit A To-Do List"

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

  def edit_list
    puts "Okay, which to-do list would you like to edit?"
    file_edit_name = gets.strip
    edit_file = "#{file_edit_name}.txt"
    @edit_file_content = parse_file(edit_file)
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

  def parse_file(file)
    filelines = File.readlines(file)
    @edit_file_content = []
    parse_lines_to_data_structure(filelines, @edit_file_content)
  end

  def list_num_tasks_left
    num_of_tasks_left = 0
    num_of_subtasks_left = 0
    @edit_file_content.each do |hash|
      if hash.keys[0] =~ /\[_\]/
        num_of_tasks_left += 1
        unless hash[hash.keys[0]].empty?
          hash[hash.keys[0]].each do |subtask|
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

  def get_completed_tasks
    @completed_tasks = []
    @edit_file_content.each do |hash|
      @completed_tasks.push(hash.keys[0]) if hash.keys[0] =~ /\[X\]/
      unless hash[hash.keys[0]].empty?
        hash[hash.keys[0]].each do |subtask|
          @completed_tasks.push("\t#{subtask}") if subtask =~ /\|X\|/
        end
      end
    end
    return @completed_tasks
  end

  def list_completed_tasks
    get_completed_tasks
    unless @completed_tasks.empty?
      puts @completed_tasks
    else
      puts "You have no completed tasks."
    end
  end

  def get_incomplete_tasks
    @incomplete_tasks = []
    @edit_file_content.each do |hash|
      @incomplete_tasks.push(hash.keys[0]) if hash.keys[0] =~ /\[_\]/
      unless hash[hash.keys[0]].empty?
        hash[hash.keys[0]].each do |subtask|
          @incomplete_tasks.push("\t#{subtask}") if subtask =~ /\|_\|/
        end
      end
    end
    return @incomplete_tasks
  end

  def list_incomplete_tasks
    get_incomplete_tasks
    unless @incomplete_tasks.empty?
      puts @incomplete_tasks
    else
      puts "All your tasks have been completed."
    end
  end

  def mark_task
    get_incomplete_tasks
    unless @incomplete_tasks.empty?
      @incomplete_tasks.each_with_index do |task, index|
        puts "(#{index + 1}) " + task 
      end
      puts "\nEnter the number in parentheses corresponding to the task you wish to mark as completed:"
      while task_number = gets.strip
        break if task_number == "quit"
        @incomplete_tasks.each_with_index do |task, index|
          @incomplete_tasks[task_number.to_i - 1].gsub!(/\[_\]|\|_\|/, "[X]")
        end
        puts "You can enter quit to finish or keep on marking off."
      end
      parse_lines_to_data_structure(,)
    else
      puts "All your tasks have been completed."
    end
  end

  def get_file_input_for(file_content)
    puts "Enter the items below. You can finish entering by typing in 'END'."
    while task = gets.strip
      return file_content if task == "END" || task == "end"
      main_task = {"#{task}" => []}
      file_content.push(main_task)
      puts "Would you like to add subtasks? Please answer in 'yes' or 'no'."
      while subtask_decision = gets.strip
        case subtask_decision
        when "yes"
          puts "Okay, enter the subtasks below. You can finish entering by typing in 'END'."
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

end
