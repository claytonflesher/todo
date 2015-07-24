require "bcrypt"
module Todo
  class User < Sequel::Model
    self.dataset = :users

    one_to_many :items

    attr_reader :empties
    
    def validate
      validates_unique :email, message: "Email is unavailable."
      validates_presence :email, message: "Must include an email."
      errors.add(:password, "Must include a password.") if BCrypt::Password.new(password) == ""
      validates_presence :first_name, message: "Must include a first name"
      validates_presence :last_name, message: "Must include a last name."
    end

    def add_task(item)
      item.user_id    = self.id
      item.save
      reload
    end
  end
end
