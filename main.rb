require 'thor'
require 'json'
require_relative 'task'
require_relative 'actions'

class MyCli < Thor
  # desc add LIST TASK, add TASK send it to default backlog list
  # ANOTHER SHORTCUT -> No add.. just list name, therefore do TASK, dn TASK etc
  desc "add TASK", "add a TASK"
  def add list, info
    add_task list, info
  end

  desc "list LIST", "read a LIST" # ls | ls bl etc
  def list list="all"
    read_list list
  end

  desc "move TASK LIST", "move TASK to LIST" # mv TASK bl
  def move task, list
    move_task task, list
  end

  desc "remove TASKID", "remove TASK with TASKID" #rm TASK
  def remove task
    remove_task task
  end

  desc "empty", "Empty all lists" # clr | clr bl etc
  def empty
    empty_lists
  end
end

MyCli.start(ARGV)
