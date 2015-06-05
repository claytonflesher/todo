module Todo
  class User
    def initialize(email: "", password: "", first_name: "", last_name: "")
      @email      = email
      @password   = password
      @first_name = first_name
      @last_name  = last_name
      @list       = [ ]
    end

    attr_reader :email, :password, :first_name, :last_name, :list

    def valid?
      email != "" && password != "" && first_name != "" && last_name != ""
    end

    def errors
      errors = [ ]
      unless email =~ /\S/
        errors << "Email can't be blank."
      end
      unless password =~ /\S/
        errors << "Password can't be blank."
      end
      unless first_name =~ /\S/
        errors << "First name can't be blank."
      end
      unless last_name =~ /\S/
        errors << "Last name can't be blank."
      end
    end

    def add_task(item)
      @list.unshift(item)
    end

    def delete_task(item)
      @list.delete(item)
    end
  end
end
