require_relative './db'
require_relative './table'

class Loader
    attr_reader :db

    def initialize
        @db = DB.new
    end

    def load_file(path)
        table = Table.new(path)
        @db.add_table(table)
    end
end
