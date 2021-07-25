class Result
    def initialize(headers, row)
        @headers = headers
        @values = row.values(headers)

        @appended_headers = []
        @appended_values = []
    end

    def add_column(original_name, new_name, rows)
        @appended_headers << new_name
        @appended_values << rows.map { |row| row.send(original_name) }.join('|')
    end

    def remove_column(name)
        index = @headers.find_index(name)
        return if index.nil?

        @headers.delete_at(index)
        @values.delete_at(index)
    end

    def headers
        return @headers + @appended_headers
    end

    def values
        return @values + @appended_values
    end
end
