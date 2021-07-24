require 'json-schema'
require_relative './array_hash_iterator'
require_relative './backward_foreign_keys'

class ForeignKeys
    include ArrayHashIterator

    def initialize(foreign_keys = '[]')
        @connections = parse(foreign_keys)
    end

    def get_backward_keys(child_table)
        backward_keys = {}
        each do |parent_table, field|
            backward_keys[parent_table.to_sym] ||= BackwardForeignKeys.new
            backward_keys[parent_table.to_sym] << { table: child_table, key: field }
        end

        return backward_keys
    end

private

    def parse(foreign_keys)
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
end
