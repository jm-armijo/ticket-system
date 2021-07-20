require 'diff/lcs'
require_relative './loader'

describe Loader do
    before(:each) do
        @path = 'this/is/a/path.json'

        @mock_table = double
        allow(Table).to receive(:new).and_return(@mock_table)

        @mock_db = double
        allow(@mock_db).to receive(:add_table).with(@mock_table)
        allow(DB).to receive(:new).and_return(@mock_db)
    end

    it 'should create a table when loading file' do
        loader = Loader.new

        expect(Table).to receive(:new).with(@path)
        loader.load_file(@path)
    end

    it 'should save table in db when loading file' do
        loader = Loader.new

        expect(@mock_db).to receive(:add_table).with(@mock_table)
        loader.load_file(@path)
    end
end
