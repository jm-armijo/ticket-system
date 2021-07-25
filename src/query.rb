class Query
    attr_reader :table
    attr_reader :conditions

    def initialize(query)
        query = truncate(query)
        @table, @conditions = parse(query)
    end

private

    def truncate(query)
        parts =  query.strip.split(';')
        Kernel.warn "Warning: The query was truncated.\n" if parts.length > 1

        return parts.first.strip
    end

    def parse(query)
        if (matches = query.match(/^select \* from (?<table>\w+)(?: where (?<condition>.+))?$/))
            return [matches[:table].to_sym, matches[:condition]]
        else
            raise 'Invalid query.'
        end
    end
end
