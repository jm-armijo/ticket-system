require 'yaml'
require_relative './row'

class Table
    attr_reader :name
    attr_reader :rows

    def initialize(path)
        @rows = []

        validate_path(path)
        save_name(path)
        load_rows(path)
    end

    def select(condition)
        return @rows if condition.nil? || condition == ''

        # rubocop:disable Lint/UnusedBlockArgument
        # rubocop:disable Security/Eval
        @rows.select { |t| eval(condition) }
        # rubocop:enable Security/Eval
        # rubocop:enable Lint/UnusedBlockArgument
    end

private

    def validate_path(path)
        raise 'Path cannot be empty' if path == ''
        raise 'Path cannot be nil' if path.nil?
        raise "Invalid path #{path}" if !File.file?(path)
    end

    def save_name(path)
        @name = File.basename(path, '.*')
    end

    def load_rows(path)
        rows = YAML.load_file(path)
        @rows = rows.map { |row| Row.new(row) }
    end
end
