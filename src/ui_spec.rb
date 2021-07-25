require_relative './ui'

describe UserInterface do
    before(:each) do
        @db = double
        @io = double
        @query = double

        allow(Query).to receive(:new).and_return(@query)
    end

    context 'on initialization' do
        it 'should save the database on initialization' do
            ui = UserInterface.new(@db, @io)

            expect(ui.instance_variable_get(:@db)).to be(@db)
        end

        it 'should save the io interface on initialization' do
            ui = UserInterface.new(@db, @io)

            expect(ui.instance_variable_get(:@io)).to be(@io)
        end
    end

    context 'when valid commands are sent' do
        it 'should exit when the user input is "exit"' do
            allow(@io).to receive(:read_input).and_return('exit')
            allow(@io).to receive(:quit)
            ui = UserInterface.new(@db, @io)

            expect(@io).to receive(:quit).and_return(false)
            expect(ui.run).to eq(false)
        end

        it 'should exit when the user input is "quit"' do
            allow(@io).to receive(:read_input).and_return('quit')
            allow(@io).to receive(:quit)
            ui = UserInterface.new(@db, @io)

            expect(@io).to receive(:quit).and_return(false)
            expect(ui.run).to eq(false)
        end
    end

    context 'when processing invalid user input' do
        before(:each) do
            @message = "Error: Cannor process query `bad command`. an error\n\n"
            allow(Query).to receive(:new).and_raise('an error')
        end

        it 'should not execute query when input is invalid' do
            allow(@io).to receive(:read_input).and_return('bad command')
            ui = UserInterface.new(@db, @io)

            expect(@db).not_to receive(:execute)
            expect { ui.run }.to output(@message).to_stderr_from_any_process
        end

        it 'should not show results when input is invalid' do
            allow(@io).to receive(:read_input).and_return('bad command')
            ui = UserInterface.new(@db, @io)

            expect(@io).not_to receive(:show_results)
            expect { ui.run }.to output(@message).to_stderr_from_any_process
        end

        it 'should return true when input is invalid' do
            allow(@io).to receive(:read_input).and_return('bad command')
            ui = UserInterface.new(@db, @io)

            response = nil
            expect { response = ui.run }.to output(@message).to_stderr_from_any_process
            expect(response).to be(true)
        end

        it 'should return true when input is invalid' do
            allow(@io).to receive(:read_input).and_return('bad command')
            ui = UserInterface.new(@db, @io)

            response = nil
            expect { response = ui.run }.to output(@message).to_stderr_from_any_process
            expect(response).to be(true)
        end
    end

    context 'when processing query with invalid condition' do
        before(:each) do
            @query = double
            allow(Query).to receive(:new).and_return(@query)
            allow(@db).to receive(:execute).and_raise('error in condition')
        end

        it 'should log error when query raises error' do
            allow(@io).to receive(:read_input).and_return('bad command')
            ui = UserInterface.new(@db, @io)

            expect(@db).to receive(:execute)
            message = "Error: Cannor process query `bad command`. error in condition\n\n"
            expect { ui.run }.to output(message).to_stderr_from_any_process
        end

        it 'should not show results when query raises error' do
            allow(@io).to receive(:read_input).and_return('bad command')
            ui = UserInterface.new(@db, @io)

            expect(@io).not_to receive(:show_results)
            message = "Error: Cannor process query `bad command`. error in condition\n\n"
            expect { ui.run }.to output(message).to_stderr_from_any_process
        end
    end

    context 'when valid queries are sent' do
        before(:each) do
            @query = double
            allow(Query).to receive(:new).and_return(@query)

            allow(@db).to receive(:execute).and_return(double)
            allow(@io).to receive(:show_results)
            allow(@query).to receive(:table).and_return('table1')
        end

        it 'should execute query when input is valid' do
            allow(@io).to receive(:read_input).and_return('valid query')
            ui = UserInterface.new(@db, @io)

            expect(@db).to receive(:execute)
            ui.run
        end

        it 'should show results when input is valid' do
            allow(@io).to receive(:read_input).and_return('valid query')

            ui = UserInterface.new(@db, @io)

            expect(@io).to receive(:show_results)
            ui.run
        end

        it 'should return true when input is valid' do
            allow(@io).to receive(:read_input).and_return('bad command')

            ui = UserInterface.new(@db, @io)
            expect(ui.run).to be(true)
        end
    end
end
