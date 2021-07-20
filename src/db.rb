class DB
    def initialize
        @tables = {}
    end

    def add_table(table)
        @tables[table.name] = table
        @tables.transform_keys!(&:to_sym)
    end

private

    def method_missing(name)
        raise "Invalid table name #{name}" if !respond_to_missing?(name)

        return @tables[name.to_sym]
    end

    def respond_to_missing?(name)
        return @tables.key?(name.to_sym)
    end
end
