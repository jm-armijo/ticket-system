require_relative './table'

describe Table do
    before(:each) do
        @path = 'this/is/a/path/to/a/test_table.json'
        allow(File).to receive(:file?).and_return(true)
    end

    it 'should raise error if initialized with empty file path' do
        expect { Table.new('') }.to raise_error(RuntimeError, 'Path cannot be empty')
    end

    it 'should raise error if initialized with empty file path' do
        expect { Table.new(nil) }.to raise_error(RuntimeError, 'Path cannot be nil')
    end

    it 'should raise error when path is valid' do
        allow(File).to receive(:file?).and_return(false)

        expect { Table.new(@path) }.to raise_error(RuntimeError, "Invalid path #{@path}")
    end

    it 'should create table when path is valid' do
        expect { Table.new(@path) }.not_to raise_error
    end

    it 'should allow getting its name after successfull initialization' do
        table = Table.new(@path)
        expect(table.name).to eq('test_table')
    end
end
