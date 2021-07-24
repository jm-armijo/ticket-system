module ArrayHashIterator
    def each
        @connections.each do |fk|
            yield [fk[:table], fk[:key]]
        end
    end

    def map
        @connections.map do |fk|
            yield [fk[:table], fk[:key]]
        end
    end
end
