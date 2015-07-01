require "time"

module Todo
  class Item

    def initialize(task: nil, notes: "", created_at: Time.now, id: nil)
      @task       = task
      @notes      = notes
      @created_at = created_at
      @id         = id
    end

    attr_reader :task, :notes, :created_at, :id

    def new?
      task.nil? && created_at != nil
    end

    def errors
      errors = [ ]
      unless task =~ /\S/
        errors << "Task can't be blank."
      end
      unless created_at.is_a?(Time)
        errors << "A creation time is needed."
      end
      errors
    end

    def valid?
      task =~ /\S/ && created_at.is_a?(Time)
    end

    def slug
      task.downcase.delete("^a-z0-9 ").gsub(/\s+/, "-")
    end
  end
end
