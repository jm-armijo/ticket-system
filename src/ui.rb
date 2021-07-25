require_relative './query'

class UserInterface
    def initialize(db, io)
        @db = db
        @io = io
    end

    def run
        input = @io.read_input

        return process_command(input) if valid_command?(input)

        # Assuming that if it's not a command, then it is a query, since we
        # will check if this is a valid query anyway.
        try_to_process_query(input)

        return true
    end

private

    def valid_command?(input)
        return ['exit', 'quit', 'q'].include?(input)
    end

    def process_command(command)
        return quit if ['exit', 'quit', 'q'].include?(command)

        return false
    end

    def quit
        @io.quit('Bye!')
        return false
    end

    def try_to_process_query(query_string)
        process_query(query_string)
    rescue StandardError => e
        warn "Error: Cannot process query `#{query_string}`. #{e.message}\n\n"
    end

    def process_query(query_string)
        return if query_string.nil? || query_string < "\21"

        query = Query.new(query_string)
        results = @db.execute(query)

        headers = results.first.headers
        rows = results.map(&:values)

        @io.show_results(headers, rows)
    end
end
