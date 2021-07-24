require_relative './io'

describe IOInterface do
    it 'should return the user input' do
        allow_any_instance_of(Kernel).to receive(:gets).and_return('user input')
        io = IOInterface.new

        input = nil
        expect { input = io.read_input }.to output(">> \n").to_stdout_from_any_process
        expect(input).to eq('user input')
    end

    it 'should return the trimmed user input if it was extra spaces' do
        allow_any_instance_of(Kernel).to receive(:gets).and_return("   \t\n  user \ninput      \n\n\n\r\t  \r")
        io = IOInterface.new

        input = nil
        expect { input = io.read_input }.to output(">> \n").to_stdout_from_any_process
        expect(input).to eq("user \ninput")
    end

    it 'should print a quit message if given' do
        allow_any_instance_of(Kernel).to receive(:puts)
        io = IOInterface.new

        message = 'See you later, alligator'
        expect_any_instance_of(Kernel).to receive(:puts).with(message)
        io.quit(message)
    end

    it 'should not print a quit message when none given' do
        allow_any_instance_of(Kernel).to receive(:puts)
        io = IOInterface.new

        expect_any_instance_of(Kernel).not_to receive(:puts)
        io.quit
    end
end
