module Todo
  class User
    def initialize(email: nil, password: nil, first_name: nil, last_name: nil)
      @email      = email
      @password   = password
      @first_name = first_name
      @last_name  = last_name
      @list       = [ ]
    end

    attr_reader :email, :password, :first_name, :last_name, :list

    def valid?
      email != nil && password != nil && first_name != nil && last_name != nil
    end

    def add_task(item)
      @list.unshift(item)
    end

    def delete_task(item)
      @list.delete(item)
    end
  end
end
