require 'sequel/plugins/timestamps'

module Todo
  class Item < Sequel::Model
    self.dataset = :items

    many_to_one :user
    plugin :timestamps

    def validate
      validates_presence :task, message: "Task cannot be blank."
    end
  end
end
