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
        it 'should not execute query when input is invalid' do
            allow(@query).to receive(:valid?).and_return(false)
            allow(@io).to receive(:read_input).and_return('bad command')
            ui = UserInterface.new(@db, @io)

            expect(@db).not_to receive(:execute)
            ui.run
        end

        it 'should not show results when input is invalid' do
            allow(@query).to receive(:valid?).and_return(false)
            allow(@io).to receive(:read_input).and_return('bad command')

            ui = UserInterface.new(@db, @io)

            expect(@io).not_to receive(:show_results)
            ui.run
        end

        it 'should return true when input is invalid' do
            allow(@query).to receive(:valid?).and_return(false)
            allow(@io).to receive(:read_input).and_return('bad command')

            ui = UserInterface.new(@db, @io)
            expect(ui.run).to be(true)
        end
    end

    context 'when valid queries are sent' do
        before(:each) do
            allow(@db).to receive(:execute)
            allow(@io).to receive(:show_results)
        end

        it 'should execute query when input is valid' do
            allow(@query).to receive(:valid?).and_return(true)
            allow(@io).to receive(:read_input).and_return('valid query')
            ui = UserInterface.new(@db, @io)

            expect(@db).to receive(:execute)
            ui.run
        end

        it 'should show results when input is valid' do
            allow(@query).to receive(:valid?).and_return(true)
            allow(@io).to receive(:read_input).and_return('valid query')

            ui = UserInterface.new(@db, @io)

            expect(@io).to receive(:show_results)
            ui.run
        end

        it 'should return true when input is valid' do
            allow(@query).to receive(:valid?).and_return(true)
            allow(@io).to receive(:read_input).and_return('bad command')

            ui = UserInterface.new(@db, @io)
            expect(ui.run).to be(true)
        end
    end
end
