require_relative './io'

describe IOInterface do
    it 'should return the user input' do
        allow_any_instance_of(Kernel).to receive(:gets).and_return('user input')
        io = IOInterface.new

        input = nil
        expect { input = io.read_input }.to output('>> ').to_stdout_from_any_process
        expect(input).to eq('user input')
    end

    it 'should return the trimmed user input if it was extra spaces' do
        allow_any_instance_of(Kernel).to receive(:gets).and_return("   \t\n  user \ninput      \n\n\n\r\t  \r")
        io = IOInterface.new

        input = nil
        expect { input = io.read_input }.to output('>> ').to_stdout_from_any_process
        expect(input).to eq("user \ninput")
    end

    it 'should print a quit message if given' do
        io = IOInterface.new

        message = 'See you later, alligator'
        expect { io.quit(message) }.to output("\n#{message}\n").to_stdout_from_any_process
        io.quit(message)
    end

    it 'should not print a quit message when none given' do
        io = IOInterface.new

        expect_any_instance_of(Kernel).not_to receive(:puts)
        io.quit
    end

    it 'should build and print Terminal::Table objects' do
        parent = { headers: double, values: [double] }
        children = { table1: { headers: double, values: [double] } }
        result = double
        allow(result).to receive(:parent).and_return(parent)
        allow(result).to receive(:children).and_return(children)

        mock_terminal = double
        allow(mock_terminal).to receive(:title=)
        allow(mock_terminal).to receive(:headings=)
        allow(mock_terminal).to receive(:rows=)
        allow(mock_terminal).to receive(:style=)
        allow(Terminal::Table).to receive(:new).and_return(mock_terminal)

        allow(Kernel).to receive(:puts).and_return(nil)

        io = IOInterface.new
        expect(Kernel).to receive(:puts).with(mock_terminal).once
        io.show_results(double, [result])
    end

    it 'should print message when there are no results to show' do
        io = IOInterface.new

        expect { io.show_results(double, []) }.to output("No results found\n").to_stderr_from_any_process
    end
end
