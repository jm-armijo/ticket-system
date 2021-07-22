require_relative './table'

class DB
    def initialize
        @tables = {}
    end

    def load_table_file(path, foreign_keys = '[]')
        table = Table.new(path, foreign_keys)
        @tables[table.name.to_sym] = table
        return table
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

    class Result
        attr_reader :parent
        attr_reader :children

        def initialize(parent)
            @parent = parent
            @children = {}
        end

        def add_child(table, child)
            @children[table.to_sym] = child
        end
    end

    def select_from_table(table_name, conditions)
        table = @tables[table_name.to_sym]
        rows = table.select(conditions)
        return rows.map { |row| create_result(table, row) }
    end

    def create_result(table, row)
        result = Result.new(row)

        table.foreign_keys.each do |fk|
            foreign_child = get_foreign_child(row, fk)
            result.add_child(fk[:table], foreign_child) if !foreign_child.nil?
        end

        return result
    end

    def get_foreign_child(row, foreign_key)
        id = row.send(foreign_key[:key])
        return @tables[foreign_key[:table].to_sym].select_by_id(id)
    end
end
