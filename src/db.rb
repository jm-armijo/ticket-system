require_relative './table'

class DB
    def initialize
        @tables = {}
    end

    def add_table(table)
        @tables[table.name] = table
        @tables.transform_keys!(&:to_sym)
    end

    def execute(query)
        query = remove_extra_commands(query)
        parsed_ok, table_name, conditions = parse_query(query)
        return parsed_ok ? select_from_table(table_name, conditions) : []
    end

private

    def remove_extra_commands(query)
        return query.split(';').first.strip
    end

    def parse_query(query)
        if (matches = query.match(/^select from (?<table>\w+)(?: where (?<condition>.+))?$/))
            return [true, matches[:table], matches[:condition]]
        else
            warn "Error: Invalid command `#{query}`."
            return []
        end
    end

    def select_from_table(table_name, conditions)
        table = @tables[table_name.to_sym]
        return table.select(conditions)
    end
end
