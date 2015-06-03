module Todo
  class User
    def initialize(email: nil, password: nil, first_name: nil, last_name: nil)
      @email = email
      @password = password
      @first_name = first_name
      @last_name = last_name
    end

    attr_reader :email, :password, :first_name, :last_name

    def valid?
      email != nil && password != nil && first_name != nil && last_name != nil
    end
  end
end
