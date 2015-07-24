require "bcrypt"
module Todo
  class User < Sequel::Model
    self.dataset = :users

    one_to_many :items

    attr_reader :empties
    
    def validate
      validates_unique :email, message: "Email is unavailable."
    end

    def add_task(item)
      item.user_id    = self.id
      item.save
      reload
    end

    def empty_fields?
      @empties = []
      empties << "Must include an email" if self.email == ""
      empties << "Must include a password" if BCrypt::Password.new(self.password) == ""
      empties << "Must include a first name" if self.first_name == ""
      empties << "Must include a last name" if self.last_name == ""
      if empties.any?
        empties
      end
    end
  end
end
