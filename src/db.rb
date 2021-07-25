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
        execute_query(query)
    rescue StandardError
        raise 'Invalid condition(s).'
    end

private

    def execute_query(query)
        table = @tables[query.table]
        rows = table.select(query.conditions)
        return rows.map { |row| create_result(table, row) }
    end

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

    def create_result(table, row)
        result = Result.new(row)

        combined_keys(table).each do |keys|
            value = row.send(keys[:my_key])
            next if value.nil?

            child = @tables[keys[:table]].select("#{keys[:other_key]} == #{value}")
            result.add_child(keys[:table], child) if !child.nil?
        end

        return result
    end

    def combined_keys(table)
        keys1 = table.foreign_keys.map  { |t, k| { table: t.to_sym, my_key: k, other_key: 'id' } }
        keys2 = table.backward_keys.map { |t, k| { table: t.to_sym, my_key: 'id', other_key: k } }

        return keys1 + keys2
    end
end
