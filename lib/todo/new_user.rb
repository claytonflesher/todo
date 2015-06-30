require 'bcrypt'

module Todo
  class NewUser < User
    def initialize(email: nil, password: nil, first_name: nil, last_name: nil)
      @email      = email
      @password   = BCrypt::Password.create(password)
      @first_name = first_name
      @last_name  = last_name
      @list       = [ ]
    end

    attr_reader :email, :password, :first_name, :last_name, :list
  end
end
