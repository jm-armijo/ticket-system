require 'diff/lcs'
require_relative './table'

describe Table do
    before(:each) do
        @path = '/this/is/a/path/to/a/test_table.json'
        allow(File).to receive(:file?).and_return(true)
        allow(YAML).to receive(:load_file).and_return([])
        allow(Row).to receive(:new).and_return(double)
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

    it 'should create one row per entry in the file' do
        row1 = { key1: 'value1', key2: 'value2' }
        row2 = { key3: 'value3', key4: 'value4' }
        allow(YAML).to receive(:load_file).and_return([row1, row2])

        expect(Row).to receive(:new).with(row1)
        expect(Row).to receive(:new).with(row2)
        Table.new(@path)
    end

    context 'when processing a query' do
        before(:each) do
            @mock_row1 = double
            @mock_row2 = double
            @mock_row3 = double
            @mock_row4 = double
            @mock_row5 = double
            @mock_row6 = double

            allow(@mock_row1).to receive(:numeric_field).and_return(-1)
            allow(@mock_row2).to receive(:numeric_field).and_return(2)
            allow(@mock_row3).to receive(:numeric_field).and_return(2.99)
            allow(@mock_row4).to receive(:numeric_field).and_return(4)
            allow(@mock_row5).to receive(:numeric_field).and_return(5)
            allow(@mock_row6).to receive(:numeric_field).and_return(144)

            allow(@mock_row1).to receive(:text_field).and_return('first')
            allow(@mock_row2).to receive(:text_field).and_return('se co nd')
            allow(@mock_row3).to receive(:text_field).and_return('3rd')
            allow(@mock_row4).to receive(:text_field).and_return('the fourth')
            allow(@mock_row5).to receive(:text_field).and_return('FIFTH')
            allow(@mock_row6).to receive(:text_field).and_return('6')

            @all_rows = [@mock_row1, @mock_row2, @mock_row3, @mock_row4, @mock_row5, @mock_row6]
            @table = Table.new(@path)
            @table.instance_variable_set(:@rows, @all_rows)
        end

        it 'should return all rows when nil filter received' do
            expect(@table.select(nil)).to eq(@all_rows)
        end

        it 'should return all rows when empty filter received' do
            expect(@table.select('')).to eq(@all_rows)
        end

        it 'should return rows 1,2,3 when filtering by numeric fields < 3' do
            expect(@table.select('t.numeric_field < 3')).to eq([@mock_row1, @mock_row2, @mock_row3])
        end

        it 'should return rows 4,5,6 when filtering by numeric fields >= 3' do
            expect(@table.select('t.numeric_field >= 3')).to eq([@mock_row4, @mock_row5, @mock_row6])
        end

        it 'should return no rows when filtering by numeric fields == 3' do
            expect(@table.select('t.numeric_field == 3')).to eq([])
        end

        it 'should return rows 1,3,5,6 when filtering by text fields with length < 6' do
            expect(@table.select('t.text_field.length < 6')).to eq([@mock_row1, @mock_row3, @mock_row5, @mock_row6])
        end

        it 'should return rows 1,3,5,6 when filtering by text fields having letter "o"' do
            expect(@table.select('t.text_field.match? /o/')).to eq([@mock_row2, @mock_row4])
        end

        it 'should return rows 1,3 when filtering by numeric fields < 3 and text fields with length < 6' do
            expect(@table.select('t.numeric_field < 3 and t.text_field.length < 6')).to eq([@mock_row1, @mock_row3])
        end
    end
end
