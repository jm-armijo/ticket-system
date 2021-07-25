require 'terminal-table'

class IOInterface
    def read_input
        print '>> '
        input = gets
        return input.nil? || input < "\21" ? input : input.strip
    end

    def quit(message = nil)
        Kernel.puts "\n#{message}" if !message.nil?
    end

    def show_results(headers, values)
        values.length.zero? ? warn('No results found') : show_table(headers, values)
    end

private

    def show_table(headers, values)
        table = Terminal::Table.new
        table.headings = headers
        table.rows     = values
        table.style    = { all_separators: true, border: :unicode_round }

        Kernel.puts table
        print "\n"
    end

    def show_separator
        Kernel.puts "\n\n#{' ' * 10}#{'═' * 100}\n\n\n"
    end
end
