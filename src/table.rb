require 'yaml'
require 'json-schema'
require_relative './row'

class Table
    attr_reader :name
    attr_reader :rows
    attr_reader :foreign_keys

    def initialize(path, foreign_keys)
        @rows = []
        @foreign_keys = parse_foreign_keys(foreign_keys)

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

    def select_by_id(id)
        return select("t._id == #{id}")
    end

private

    def parse_foreign_keys(foreign_keys)
        schema = {
            'type'       => 'object',
            'required'   => ['table', 'key'],
            'properties' => {
                'table' => { 'type' => 'string' },
                'key'   => { 'type' => 'string' }
            }
        }

        JSON::Validator.validate!(schema, foreign_keys, list: true, strict: true)
        parsed_keys = JSON.parse(foreign_keys)

        return parsed_keys.map { |key| key.transform_keys(&:to_sym) }
    end

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
