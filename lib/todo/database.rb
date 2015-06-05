require "pstore"

module Todo
  class Database
    READ_ONLY = true
    def initialize
      @db = PStore.new(File.join(__dir__, *%w[.. .. db items.pstore]))
    end

    attr_reader :db

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
  end
end
