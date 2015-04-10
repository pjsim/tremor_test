class Task
  attr_reader :id, :info, :created_at, :updated_at

  def initialize(list, info, task_id)
    @id = task_id
    @info = info
    @created_at = Time.now.to_s
    @updated_at = Time.now.to_s
  end

  def info=(info)
    @info = info
    @updated_at = Time.now.to_s
  end
end

class Maintask < Task
  attr_reader :subtasks

  def initialize(list, info, task_id)
    super
    @subtasks = []
  end

  def add_subtask(info)
    sub = Subtask.new(info)
    @subtasks.push(sub.to_json)
  end

  def to_json
    {'id' =>  @id, 'info' =>  @info, 'created_at' =>  @created_at, 'updated_at' =>  @updated_at, 'subtasks' =>  @subtasks}.to_json
  end
end

class Subtask < Task
  attr_reader :status

  def initialize(list, info)
    super
    @status = 0
  end

  def status=(status)
    @status = status
    @updated_at = Time.now.to_s
  end
  def to_json
    {'id' =>  @id, 'info' =>  @info, 'created_at' =>  @created_at, 'updated_at' =>  @updated_at, 'status' =>  @status}.to_json
  end
end
