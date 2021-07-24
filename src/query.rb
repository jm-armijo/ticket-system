class Query
    attr_reader :table
    attr_reader :conditions

    def initialize(query)
        query = truncate(query)
        @table, @conditions = parse(query)
    end

    def valid?
        return !@table.nil?
    end

private

    def truncate(query)
        parts =  query.strip.split(';')
        warn 'Warning: The query was truncated.' if parts.length > 1

        return parts.first.strip
    end

    def parse(query)
        if (matches = query.match(/^select \* from (?<table>\w+)(?: where (?<condition>.+))?$/))
            return [matches[:table].to_sym, matches[:condition]]
        else
            warn "Error: Invalid command `#{query}`."
            return []
        end
    end
end
