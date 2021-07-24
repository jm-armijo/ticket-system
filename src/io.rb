require 'terminal-table'

class IOInterface
    def read_input
        puts '>> '
        return gets.strip
    end

    def quit(message = nil)
        Kernel.puts message if !message.nil?
    end

    def show_results(name, results)
        results.each_with_index do |result, index|
            show_table(name, result.parent)
            result.children.each_pair { |t, c| show_table(t, c) }
            show_separator if index < results.length - 1
        end
    end

private

    def show_table(name, result)
        return if result[:values].length.zero?

        table = Terminal::Table.new
        table.title    = name.capitalize if name != ''
        table.headings = result[:headers]
        table.rows     = result[:values]
        table.style    = { all_separators: true, border: :unicode_round }

        Kernel.puts table
    end

    def show_separator
        Kernel.puts "\n\n#{' ' * 10}#{'═' * 100}\n\n\n"
    end
end
