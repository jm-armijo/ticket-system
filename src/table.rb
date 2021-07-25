require 'yaml'
require_relative './row'

class Table
    attr_reader :name
    attr_reader :rows
    attr_reader :foreign_keys
    attr_accessor :backward_keys

    def initialize(path, foreign_keys)
        @rows = []
        @index_table = {}
        @foreign_keys = foreign_keys
        @backward_keys = []

        validate_path(path)
        save_name(path)
        load_rows(path)
        create_index_tables
    end

    def create_index_tables
        columns = [:_id]
        @foreign_keys.each { |_t, key| columns << key.to_sym }

        create_index_tables_for_columns(columns)
    end

    def select(condition)
        return @rows if condition.nil? || condition == ''

        # rubocop:disable Security/Eval
        @rows.select { |t| t.instance_eval { eval(condition) } }
        # rubocop:enable Security/Eval
    end

    def select_by_key(key, value)
        index_table = @index_table[key.to_sym]
        return index_table.key?(value) ? index_table[value] : []
    end

private

    def validate_path(path)
        raise 'Path cannot be empty' if path == ''
        raise 'Path cannot be nil' if path.nil?
        raise "Invalid path #{path}" if !File.file?(path)
    end

    def save_name(path)
        @name = File.basename(path, '.*').to_sym
    end

    def load_rows(path)
        rows = YAML.load_file(path)
        @rows = rows.map { |row| Row.new(row) }
    end

    def create_index_tables_for_columns(columns)
        @rows.each do |row|
            columns.each do |column|
                next if row.nil?

                key_value = row.send(column)
                @index_table[column] ||= {}
                @index_table[column][key_value] ||= []
                @index_table[column][key_value] << row
            end
        end
    end
end
