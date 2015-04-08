require 'thor'
require 'json'
require_relative 'task'

def empty_lists
  File.write 'backlog.json', []
  File.write 'todo.json', []
  File.write 'doing.json', []
  File.write 'done.json', []
  File.write 'archive.json', []
end

def task_adder listshort, listfull, info
  ts = JSON.parse(File.read("#{listfull}.json"))
  t = Maintask.new listshort, info
  ts << t.to_json
  File.write("#{listfull}.json", ts)
end

def task_remover task_id
  if task_id[0..1] == 'BL'
    list = 'backlog.json'
  elsif task_id[0..1] == 'TD'
    list = 'todo.json'
  elsif task_id[0..1] == 'DO'
    list = 'doing.json'
  elsif task_id[0..1] == 'DN'
    list = 'done.json'
  elsif task_id[0..1] == 'AR'
    list = 'archive.json'
  else
    raise 'NO'
  end
  ts = JSON.parse(File.read(list))
  found_task = ts.find { |t| JSON.parse(t)["id"] == task_id }
  ts.delete(found_task)
  File.write(list, ts)
end

def task_mover task_id, to_list
  if task_id[0..1] == 'BL'
    from_list = 'backlog.json'
  elsif task_id[0..1] == 'TD'
    from_list = 'todo.json'
  elsif task_id[0..1] == 'DO'
    from_list = 'doing.json'
  elsif task_id[0..1] == 'DN'
    from_list = 'done.json'
  elsif task_id[0..1] == 'AR'
    from_list = 'archive.json'
  else
    raise 'NO'
  end
  from_tasks = JSON.parse(File.read(from_list))
  to_tasks = JSON.parse(File.read(to_list))
  found_task = from_tasks.find { |t| JSON.parse(t)["id"] == task_id }
  to_tasks << found_task
  from_tasks.delete(found_task)
  File.write(from_list, from_tasks)
  File.write(to_list, to_tasks)
end

def add_task list, info
  list = list.downcase
  case list
  when "bl", "backlog"
    task_adder "BL", "backlog", info
  when "td", "todo", "to do", "to-do"
    task_adder "TD", "todo", info
  when "do", "doing"
    task_adder "DO", "doing", info
  when "dn", "done"
    task_adder "DN", "done", info
  when "ar", "archive", "archived"
    task_adder "AR", "archive", info
  else
    puts "Tremor: add - This list doesn't exist"
  end
end

def list_reader list
  if list == "all"
    json_lists = ['backlog.json', 'todo.json', 'doing.json', 'done.json', 'archive.json']
    json_list = []
    json_lists.each do |x|
      json_list << JSON.parse(File.read(x))
    end
  else
    json_list = JSON.parse(File.read("#{list}.json"))
  end
  puts "ID\tINFO"
  puts "--\t----"
  json_list.each do |task|
    unless list == "all"
      json_task = JSON.parse(task.to_s)
      puts "#{json_task['id']}\t#{json_task['info']}"
    else
      task.each do |taskm|
        json_task = JSON.parse(taskm.to_s)
        puts "#{json_task['id']}\t#{json_task['info']}"
      end
    end
  end
end

def read_list list
  case list
  when "all"
    list_reader "all"
  when "BL"
    list_reader "backlog"
  when "TD"
    list_reader "todo"
  when "DO"
    list_reader "doing"
  when "DN"
    list_reader "done"
  when "AR"
    list_reader "archive"
  end
end

class MyCli < Thor
  desc "add TASK", "add a TASK"
  def add list, info
    add_task list, info
  end

  desc "list LIST", "read a LIST"
  def list list="all"
    read_list list
  end

  desc "move TASK LIST", "move TASK to LIST"
  def move task, list
    task_mover task, list
  end

  desc "del", "del"
  def remove task
    task_remover task
  end

  desc "empty", "empty all lists"
  def empty
    empty_lists
  end
end

MyCli.start(ARGV)
