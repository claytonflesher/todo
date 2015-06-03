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
        db[:list] ||= []
        db[:users] ||= {}
      end
    end

    def save_item(item)
      db.transaction do
        db[:list].unshift(item)
      end
    end

    def save_user(user)
      db.transaction do
        db[:users][user.email] = user
      end
    end

    def load(slug)
      db.transaction(READ_ONLY) do
        db[:list].find { |item| item.slug == slug }
      end
    end

    def all
      db.transaction(READ_ONLY) do
        Array(db[:list])
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
