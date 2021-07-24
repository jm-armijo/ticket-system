require_relative './result'
require_relative './table'

class DB
    def initialize
        @tables = {}
    end

    def load_table_file(path, foreign_keys)
        table = create_table(path, foreign_keys)
        create_backward_keys(table)
    end

    def execute(query)
        query = remove_extra_commands(query)
        parsed_ok, table_name, conditions = parse_query(query)
        return parsed_ok ? select_from_table(table_name, conditions) : []
    end

private

    def create_backward_keys(table)
        backward_keys = table.foreign_keys.get_backward_keys(table.name)
        link_backward_keys(backward_keys)
    end

    def link_backward_keys(backward_keys)
        backward_keys.each do |parent_name, table_backward_keys|
            # The error refers to the foreign key creation when it actually
            # occurs during the creation of backward_keys. However, backward_keys
            # are an internal implementarion, unknown to final users, and
            # the solution is still the same (a missing table must be loaded).
            raise "Cannot create foreign key: table `#{parent_name}` does not exist" if !@tables.key?(parent_name)

            @tables[parent_name].backward_keys = table_backward_keys
        end
    end

    def create_table(path, foreign_keys)
        table = Table.new(path, foreign_keys)
        @tables[table.name.to_sym] = table
        return table
    end

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
        rows = table.select(conditions)
        return rows.map { |row| create_result(table, row) }
    end

    def create_result(table, row)
        result = Result.new(row)

        combined_keys(table).each do |keys|
            value = row.send(keys[:my_key])
            child = @tables[keys[:table]].select("t.#{keys[:other_key]} == #{value}")
            result.add_child(table.name, child) if !child.nil?
        end

        return result
    end

    def combined_keys(table)
        keys1 = table.foreign_keys.map  { |t, k| { table: t, my_key: k, other_key: 'id' } }
        keys2 = table.backward_keys.map { |t, k| { table: t, my_key: 'id', other_key: k } }

        return keys1 + keys2
    end
end
