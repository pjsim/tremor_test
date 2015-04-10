require 'set'

def empty_lists
  File.write 'backlog.json', []
  File.write 'todo.json', []
  File.write 'doing.json', []
  File.write 'done.json', []
  File.write 'archive.json', []
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
  list_reader "all"
end

def task_adder listshort, listfull, info
  ts = JSON.parse(File.read("#{listfull}.json"))
  ids = Set.new
  ts.each { |t| ids << JSON.parse(t)['id'][2..3] }
  task_id = "#{listshort}#{'%02i' % (ids.max.to_i + 1)}"
  t = Maintask.new listshort, info, task_id
  ts << t.to_json
  File.write("#{listfull}.json", ts)
end

def remove_task task_id
  shortlist = task_id[0..1]
  task_id_check = shortlist.downcase
  case task_id_check
  when 'bl'
    list = 'backlog.json'
  when 'td'
    list = 'todo.json'
  when 'do'
    list = 'doing.json'
  when 'dn'
    list = 'done.json'
  when 'ar'
    list = 'archive.json'
  else
    raise 'Invalid ID'
  end
  task_remover task_id, list, shortlist
  list_reader "all"
end

def task_remover task_id, list, shortlist
  # sort tasks by created_at then reasign IDs
  # require 'time'
  # t2 = Time.parse(d2)
  ts = JSON.parse(File.read(list))
  found_task = ts.find { |t| JSON.parse(t)["id"] == task_id }
  ts.delete(found_task)

  tn = []
  ts.each_with_index do |t, i|
    i += 1
    t = JSON.parse(t)
    t['id'] = "#{shortlist}#{'%02i' % i}"
    tn << t.to_json
  end
  File.write(list, tn)
end

def move_task task_id, to_list
  if task_id[0..1] == 'BL'
    from_list = 'backlog.json'
    from_short = "BL"
  elsif task_id[0..1] == 'TD'
    from_list = 'todo.json'
    from_short = "TD"
  elsif task_id[0..1] == 'DO'
    from_list = 'doing.json'
    from_short = "DO"
  elsif task_id[0..1] == 'DN'
    from_list = 'done.json'
    from_short = "DN"
  elsif task_id[0..1] == 'AR'
    from_list = 'archive.json'
    from_short = "AR"
  else
    raise 'Invalid ID'
  end

  to_list = to_list.downcase
  case to_list
  when "bl", "backlog"
    to_list = 'backlog.json'
    to_short = "BL"
  when "td", "todo", "to do", "to-do"
    to_list = 'todo.json'
    to_short = "TD"
  when "do", "doing"
    to_list = 'doing.json'
    to_short = "DO"
  when "dn", "done"
    to_list = 'done.json'
    to_short = "DN"
  when "ar", "archive", "archived"
    to_list = 'archive.json'
    to_short = "AR"
  else
    puts "Tremor: add - This list doesn't exist"
  end

  task_mover task_id, from_list, to_list, from_short, to_short
  list_reader "all"
end

def task_mover task_id, from_list, to_list, from_short, to_short
  from_tasks = JSON.parse(File.read(from_list))
  to_tasks = JSON.parse(File.read(to_list))

  found_task = from_tasks.find { |t| JSON.parse(t)["id"] == task_id }

  to_tasks << found_task
  from_tasks.delete(found_task)

  new_from = []
  new_to = []

  from_tasks.each_with_index do |t, i|
    i += 1
    t = JSON.parse(t)
    t['id'] = "#{from_short}#{'%02i' % i}"
    new_from << t.to_json
  end
  File.write(from_list, new_from)

  to_tasks.each_with_index do |t, i|
    i += 1
    t = JSON.parse(t)
    t['id'] = "#{to_short}#{'%02i' % i}"
    new_to << t.to_json
  end
  File.write(to_list, new_to)


  # File.write(from_list, from_tasks)
  # File.write(to_list, to_tasks)
end

def list_reader list
  list = "all"
  if list == "all"
    puts "BACKLOG\t\t\t\tTODO\t\t\t\tDOING\t\t\t\tDONE\t\t\t\tARCHIVE"
    puts "=======\t\t\t\t====\t\t\t\t=====\t\t\t\t====\t\t\t\t======="

    bl_tasks = JSON.parse(File.read('backlog.json'))
    td_tasks = JSON.parse(File.read('todo.json'))
    do_tasks = JSON.parse(File.read('doing.json'))
    dn_tasks = JSON.parse(File.read('done.json'))
    ar_tasks = JSON.parse(File.read('archive.json'))

    max_rows = [bl_tasks.count, td_tasks.count, do_tasks.count, dn_tasks.count, ar_tasks.count].max

    (1..max_rows).each do |row|
      task_row_id = "#{'%02i' % row}"
      bl_task = td_task = do_task = dn_task = ar_task = "\t"
      bl_tasks.each do |t|
        bl_task = "#{JSON.parse(t)['id']}\t#{JSON.parse(t)['info'][0..6]}" if JSON.parse(t)['id'].include? task_row_id
      end
      td_tasks.each do |t|
        td_task = "#{JSON.parse(t)['id']}\t#{JSON.parse(t)['info'][0..6]}" if JSON.parse(t)['id'].include? task_row_id
      end
      do_tasks.each do |t|
        do_task = "#{JSON.parse(t)['id']}\t#{JSON.parse(t)['info'][0..6]}" if JSON.parse(t)['id'].include? task_row_id
      end
      dn_tasks.each do |t|
        dn_task = "#{JSON.parse(t)['id']}\t#{JSON.parse(t)['info'][0..6]}" if JSON.parse(t)['id'].include? task_row_id
      end
      ar_tasks.each do |t|
        ar_task = "#{JSON.parse(t)['id']}\t#{JSON.parse(t)['info'][0..6]}" if JSON.parse(t)['id'].include? task_row_id
      end
      puts "#{bl_task}\t\t\t#{td_task}\t\t\t#{do_task}\t\t\t#{dn_task}\t\t\t#{ar_task}"
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
