module Todo
  class User < Sequel::Model
    self.dataset = :users

    one_to_many :items

    def validate
      validates_unique :email, message: "Email is unavailable."
    end

    def add_task(item)
      item.user_id    = self.id
      item.save
      reload
    end
  end
end
