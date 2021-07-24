class Result
    attr_reader :parent
    attr_reader :children

    def initialize(parent)
        headers = parent.headers
        rows = extract_rows(headers, [parent])

        @parent = { headers: headers, values: rows }
        @children = {}
    end

    def add_child(table, table_children)
        headers = extract_headers(table_children)
        rows = extract_rows(headers, table_children)

        @children[table] = { headers: headers, values: rows }
    end

private

    def extract_headers(result_sets)
        headers = []
        result_sets.each do |result_set|
            headers = (headers + result_set.headers).uniq
        end
        return headers
    end

    def extract_rows(headers, result_sets)
        rows = []
        result_sets.each do |row|
            rows << headers.map { |h| row.send(h) }
        end
        return rows
    end
end
