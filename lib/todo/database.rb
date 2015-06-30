require "pg"
require_relative "user"

module Todo
  class Database
    READ_ONLY = true
    def initialize
      @db = PG.connect(dbname: 'todo')
      db.prepare("new_user", "INSERT INTO users (email, password, first_name, last_name, list) VALUES ($1, $2, $3, $4, $5);")
      db.prepare("load_up", "SELECT * FROM users WHERE email = $1;")
      db.prepare("emails", "SELECT email FROM users WHERE email = $1;")
    end

    attr_reader :db

    def valid?(email)
      check_if_email_available(email)
    end

    def errors(email)
      errors = [ ]
      unless check_if_email_available(email)
        errors << "#{email} is already taken. Please login or use another."
      end
    end

    def setup
      db.exec("CREATE TABLE IF NOT EXISTS users ( 
              email text, 
              password text, 
              first_name text, 
              last_name text );"
             )
    end

    def save_user(user)
      db.exec_prepared("new_user", [user.email, user.password, user.first_name, user.last_name, user.list])
    end

    def authenticate(email:, password:) 
      user_data = {:email => nil, :password => nil }
      db.exec_prepared("load_up", [email]).each { |result|
        result.each { |line|
          user_data[line[0].to_sym] = line[1]
        }
      }
      unless user_data[:email] == nil
        user = User.new(email: user_data[:email], password: user_data[:password], first_name: user_data[:first_name], last_name: user_data[:last_name], list: user_data[:list])
        if user.email == email && user.password == password
          return user
        end
      end
      nil
    end

    def load_user(email)
      user_data = {}
      db.exec_prepared("load_up", [email]).each { |result|
        result.each { |line|
          user_data[line[0].to_sym] = line[1]
        }
      }
      if user_data.empty?
        nil
      else
        User.new(email: user_data[:email], password: user_data[:password], first_name: user_data[:first_name], last_name: user_data[:last_name], list: user_data[:list])
      end
    end
    
    private

    def check_if_email_available(email)
      user_data = {:email => nil }
      db.exec_prepared("emails", [email]).each { |result|
        result.each { |line|
          user_data[line[0].to_sym] = line[1]
        }
      }
      user_data[:email].nil?
    end
  end
end
