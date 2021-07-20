require 'diff/lcs'
require_relative './table'

describe Table do
    before(:each) do
        @path = '/this/is/a/path/to/a/test_table.json'
        allow(File).to receive(:file?).and_return(true)
        allow(YAML).to receive(:load_file).and_return([])
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

    it 'should have 0 rows when loading empty file' do
        table = Table.new(@path)
        expect(table.rows.length).to eq(0)
    end

    it 'should have 1 rows when loading file with one entry' do
        content = [{ key1: 'value1', key2: 'value2' }]
        allow(YAML).to receive(:load_file).and_return(content)

        table = Table.new(@path)
        expect(table.rows.length).to eq(1)
    end

    it 'should have 2 rows when loading file with two entry' do
        content = [
            { key1: 'value1', key2: 'value2' },
            { key3: 'value3', key4: 'value4' }
        ]
        allow(YAML).to receive(:load_file).and_return(content)

        table = Table.new(@path)
        expect(table.rows.length).to eq(2)
    end
end
