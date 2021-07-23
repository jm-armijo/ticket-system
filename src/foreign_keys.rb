require 'forwardable'
require 'json-schema'

class ForeignKeys
    def initialize(foreign_keys = '[]')
        @foreign_keys = parse(foreign_keys)
    end

    def each
        @foreign_keys.each do |fk|
            yield [fk[:table], fk[:key]]
        end
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
