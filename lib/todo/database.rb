require "pstore"

module Todo
  class Database
    READ_ONLY = true
    def initialize
      @db = PStore.new(File.join(__dir__, *%w[.. .. db items.pstore]))
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
      db.transaction do
        db[:users] ||= {}
      end
    end

    def save_user(user)
      db.transaction do
        db[:users][user.email] = user
      end
    end

    def authenticate(email:, password:)
      db.transaction(READ_ONLY) do
        if db[:users].include?(email) && db[:users][email].password == password
          db[:users][email]
        else
          nil
        end
      end
    end

    def load_user(email)
      db.transaction(READ_ONLY) do
        db[:users][email]
      end
    end
    
    private

    def check_if_email_available(email)
      db.transaction do
        db[:users][email].nil?
      end
    end
  end
end
