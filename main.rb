require 'thor'
require 'json'
require_relative 'task'

def add_task list, info
  case list
  when "BL"
    t = Maintask.new "BL", info
    File.write('backlog.json', t.to_json)
  when "TD"
    t = Maintask.new "TD", info
    File.write('todo.json', t.to_json)
  when "DO"
    t = Maintask.new "DO", info
    File.write('doing.json', t.to_json)
  when "DN"
    t = Maintask.new "DN", info
    File.write('done.json', t.to_json)
  when "AR"
    t = Maintask.new "AR", info
    File.write('archive.json', t.to_json)
  end
end

def read_list list
  case list
  when "all"
    jn = []
    backlog = JSON.parse(File.read('backlog.json'))
    todo = JSON.parse(File.read('todo.json'))
    doing = JSON.parse(File.read('doing.json'))
    done = JSON.parse(File.read('done.json'))
    archive = JSON.parse(File.read('archive.json'))
    jn.push(backlog)
    jn.push(todo)
    jn.push(doing)
    jn.push(done)
    jn.push(archive)
    puts "ID\tINFO"
    puts "--\t----"
    jn.each do |x|
      if x['info'].length > 20
        info = "#{x['info'][0..20]}.."
      else
        info = x['info']
      end
      puts "#{x['id']}\t#{info}"
    end
  when "BL"
    puts JSON.parse(File.read('backlog.json'))
  when "TD"
    puts JSON.parse(File.read('todo.json'))
  when "DO"
    puts JSON.parse(File.read('doing.json'))
  when "DN"
    puts JSON.parse(File.read('done.json'))
  when "AR"
    puts JSON.parse(File.read('archive.json'))
  end
end

class MyCli < Thor
  desc "add TASK", "add a TASK"
  def cli_task(info)
    add_task "BL", info
  end
end

MyCli.start(ARGV)
