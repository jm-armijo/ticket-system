class IOInterface
    def read_input
        puts '>> '
        return gets.strip
    end

    def quit(message = nil)
        puts message if !message.nil?
    end

    def show_results(results); end
end
