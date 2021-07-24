#!/usr/bin/env ruby

require_relative './src/db'
require_relative './src/io'
require_relative './src/ui'
require_relative './src/keys/foreign_keys'

class Main
    def initialize
        db = DB.new
        io = IOInterface.new
        @ui = UserInterface.new(db, io)

        load_data(db)
    end

    def run
        while @ui.run; end
    end

private

    def load_data(db)
        users_fk = ForeignKeys.new('[]')
        db.load_table_file('users.json', users_fk)

        tickets_fks = ForeignKeys.new('[{"key": "assignee_id", "table": "users"}]')
        db.load_table_file('tickets.json', tickets_fks)
    end
end

Main.new.run if $PROGRAM_NAME == __FILE__
