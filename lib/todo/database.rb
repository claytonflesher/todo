require "pstore"

module Todo
  class Database
    READ_ONLY = true
    def initialize
      @db = PStore.new(File.join(__dir__, *%w[.. .. db items.pstore]))
    end

    attr_reader :db
    def save(item)
      db.transaction do
        db[:list] ||= []
        db[:list].unshift(item)
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
  end
end
