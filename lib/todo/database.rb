require "pg"
require "time"
require "bcrypt"
require_relative "user"
require_relative "item"

module Todo
  class Database
    READ_ONLY = true
    def initialize
      @db = PG.connect(dbname: 'todo')
      @db.type_map_for_results = PG::BasicTypeMapForResults.new(@db)
      setup
      db.prepare("new_user", "INSERT INTO users (email, password, first_name, last_name) VALUES ($1, $2, $3, $4);")
      db.prepare("load_items", "SELECT * FROM items WHERE email = $1;")
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
              id serial primary key,
              email text,
              password text,
              first_name text,
              last_name text );"
             )

      db.exec("CREATE TABLE IF NOT EXISTS items (
              id serial primary key,
              email text,
              task text,
              notes text,
              created_at timestamp without time zone );"
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
      user_data = find_user_by_email(email)

      unless user_data[:email] == nil
        user = User.new(email: user_data[:email], password: user_data[:password], first_name: user_data[:first_name], last_name: user_data[:last_name], list: [ ])
        if user.email == email && BCrypt::Password.new(user.password) == password
          load_items_for_user(user)
          return user
        end
      end

      nil
    end

    def save_item(item, user)
      db.exec("INSERT INTO items (email, task, notes, created_at) VALUES ($1, $2, $3, $4)",
              [ user.email, item.task, item.notes, item.created_at ]
      )
    end

    def load_user(email)
      user_data = find_user_by_email(email)

      if user_data.empty?
        nil
      else
        user = User.new(email: user_data[:email], password: user_data[:password], first_name: user_data[:first_name], last_name: user_data[:last_name], list: [] )
        load_items_for_user(user)
        user
      end
    end

    def delete_task(id)
      db.exec("DELETE FROM items WHERE id = $1", [ id ])
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

    def load_items_for_user(user)
      db.exec_prepared("load_items", [user.email]).each { |result|
          user.add_task(Item.new(
            task: result["task"],
            notes: result["notes"],
            created_at: result["created_at"],
            id: result["id"])
          )
      }
    end

    def find_user_by_email(email)
      user_data = Hash.new
      db.exec("SELECT * FROM users WHERE email = $1 LIMIT 1;", [email]).each { |result|
        user_data[:email]      = result["email"]
        user_data[:password]   = result["password"]
        user_data[:last_name]  = result["last_name"]
        user_data[:first_name] = result["first_name"]
      }
      user_data
    end

  end
end
