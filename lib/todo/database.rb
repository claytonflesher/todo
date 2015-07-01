require "pg"
require "time"
require_relative "user"
require_relative "item"

module Todo
  class Database
    READ_ONLY = true
    def initialize
      @db = PG.connect(dbname: 'todo')
      db.prepare("new_user", "INSERT INTO users (email, password, first_name, last_name) VALUES ($1, $2, $3, $4);")
#      db.prepare("new_item", "IF NOT EXISTS (SELECT *
#                 FROM items WHERE email = $1 AND task = $2 AND created_at = $4)
#                 THEN INSERT INTO items (email, task, note, created_at) VALUES ($1, $2, $3, $4)
#                 END IF;
#                 END;")
      db.prepare("load_items", "SELECT * FROM items WHERE email = $1;")
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
      db.exec_prepared("new_user", [user.email, user.password, user.first_name, user.last_name])
      if user.list != []
        user.list.each do |item|
          db.exec_prepared("new_item", [user.email, item.task, item.notes, item.created_at.to_i])
        end
      end
    end

    def authenticate(email:, password:) 
      user_data = {:email => nil, :password => nil }
      tasks     = [ ]
      db.exec_prepared("load_up", [email]).each { |result|
        result.each { |line|
          user_data[line[0].to_sym] = line[1]
        }
      }
      db.exec_prepared("load_items", [email]).each { |result|
        result.each { |line|
          tasks << line
        }
      }
      tasks.map { |item| Item.new(task: item["task"], notes: item["note"], created_at: Time.at(item["created_at"].to_i)) }
      unless user_data[:email] == nil
        user = User.new(email: user_data[:email], password: user_data[:password], first_name: user_data[:first_name], last_name: user_data[:last_name], list: tasks)
        if user.email == email && user.password == password
          return user
        end
      end
      nil
    end

    def load_user(email)
      user_data = {}
      tasks     = []
      db.exec_prepared("load_up", [email]).each { |result|
        result.each { |line|
          user_data[line[0].to_sym] = line[1]
        }
      }
      db.exec_prepared("load_items", [email]).each { |result|
        result.each { |line|
          tasks << line
        }
      }
      tasks.map { |item| Item.new(task: item["task"], notes: item["note"], created_at: Time.at(item["created_at"].to_i)) }
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
