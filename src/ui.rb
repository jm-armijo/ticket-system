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
        process_query(input)

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

    def process_query(query_string)
        return if query_string.nil? || query_string < "\21"

        query = Query.new(query_string)
        if query.valid?
            results = @db.execute(query)
            @io.show_results(query.table, results)
        end
    end
end
