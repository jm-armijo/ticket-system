require_relative './main'

describe Main do
    before(:each) do
        @mock_db  = double
        @mock_io  = double
        @mock_ui  = double
        @mock_fk1 = double
        @mock_fk2 = double

        allow(@mock_db).to receive(:load_table_file)

        allow(DB).to receive(:new).and_return(@mock_db)
        allow(IOInterface).to receive(:new).and_return(@mock_io)
        allow(UserInterface).to receive(:new).and_return(@mock_ui)
        allow(ForeignKeys).to receive(:new).and_return(@mock_fk1, @mock_fk2)
    end

    it 'should create a new user interface on initialization' do
        expect(UserInterface).to receive(:new).with(@mock_db, @mock_io).and_return(@mock_ui)
        Main.new
    end

    it 'should save a new user interface on initialization' do
        main = Main.new
        expect(main.instance_variable_get(:@ui)).to be(@mock_ui)
    end

    it 'should save a new user interface on initialization' do
        expect(@mock_db).to receive(:load_table_file).with('users.json', @mock_fk1)
        expect(@mock_db).to receive(:load_table_file).with('tickets.json', @mock_fk2)
        Main.new
    end

    it 'should call ui.run 1 time' do
        allow(@mock_ui).to receive(:run).and_return(false)
        main = Main.new

        expect(@mock_ui).to receive(:run).once.and_return(false)
        main.run
    end

    it 'should call ui.run 3 times' do
        allow(@mock_ui).to receive(:run).and_return(true, true, false)
        main = Main.new

        expect(@mock_ui).to receive(:run).ordered.and_return(true)
        expect(@mock_ui).to receive(:run).ordered.and_return(true)
        expect(@mock_ui).to receive(:run).ordered.and_return(false)
        main.run
    end
end
