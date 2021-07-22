require 'diff/lcs'
require_relative './table'

describe Table do
    before(:each) do
        @path = '/this/is/a/path/to/a/test_table.json'
        @foreign_keys = '[]'
        allow(File).to receive(:file?).and_return(true)
        allow(YAML).to receive(:load_file).and_return([])
        allow(Row).to receive(:new).and_return(double)
    end

    it 'should raise error if initialized with empty file path' do
        expect { Table.new('', @foreign_keys) }.to raise_error(RuntimeError, 'Path cannot be empty')
    end

    it 'should raise error if initialized with empty file path' do
        expect { Table.new(nil, @foreign_keys) }.to raise_error(RuntimeError, 'Path cannot be nil')
    end

    it 'should raise error when path is invalid' do
        allow(File).to receive(:file?).and_return(false)

        expect { Table.new(@path, @foreign_keys) }.to raise_error(RuntimeError, "Invalid path #{@path}")
    end

    it 'should create table when path is valid' do
        expect { Table.new(@path, @foreign_keys) }.not_to raise_error
    end

    it 'should raise error when foreign keys format is invalid' do
        @foreign_keys = '[xxxxx]'
        expect { Table.new(@path, @foreign_keys) }.to raise_error(JSON::Schema::ValidationError)
    end

    it 'should raise error when foreign keys is not a JSON array' do
        @foreign_keys = '{"key": "value"}'
        expect { Table.new(@path, @foreign_keys) }.to raise_error(JSON::Schema::ValidationError)
    end

    it 'should raise error when foreign keys do not have the "table" field' do
        @foreign_keys = '[{"key": "value"}]'
        expect { Table.new(@path, @foreign_keys) }.to raise_error(JSON::Schema::ValidationError)
    end

    it 'should raise error when foreign keys do not have the "key" field' do
        @foreign_keys = '[{"table": "value"}]'
        expect { Table.new(@path, @foreign_keys) }.to raise_error(JSON::Schema::ValidationError)
    end

    it 'should raise error when foreign keys include unexpected field' do
        @foreign_keys = '[{"table": "t", "key": "k", "fake": "f"}]'
        expect { Table.new(@path, @foreign_keys) }.to raise_error(JSON::Schema::ValidationError)
    end

    it 'should save foreign keys when valid' do
        @foreign_keys = '[{"table": "t", "key": "k"}]'
        table = Table.new(@path, @foreign_keys)
        expect(table.foreign_keys).to eq([{ table: 't', key: 'k' }])
    end

    it 'should allow getting its name after successfull initialization' do
        table = Table.new(@path, @foreign_keys)
        expect(table.name).to eq('test_table')
    end

    it 'should have 0 rows when loading empty file' do
        table = Table.new(@path, @foreign_keys)
        expect(table.rows.length).to eq(0)
    end

    it 'should have 1 rows when loading file with one entry' do
        content = [{ key1: 'value1', key2: 'value2' }]
        allow(YAML).to receive(:load_file).and_return(content)

        table = Table.new(@path, @foreign_keys)
        expect(table.rows.length).to eq(1)
    end

    it 'should have 2 rows when loading file with two entry' do
        content = [
            { key1: 'value1', key2: 'value2' },
            { key3: 'value3', key4: 'value4' }
        ]
        allow(YAML).to receive(:load_file).and_return(content)

        table = Table.new(@path, @foreign_keys)
        expect(table.rows.length).to eq(2)
    end

    it 'should create one row per entry in the file' do
        row1 = { key1: 'value1', key2: 'value2' }
        row2 = { key3: 'value3', key4: 'value4' }
        allow(YAML).to receive(:load_file).and_return([row1, row2])

        expect(Row).to receive(:new).with(row1)
        expect(Row).to receive(:new).with(row2)
        Table.new(@path, @foreign_keys)
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

            mock_nil = double
            allow(mock_nil).to receive(:==).and_return(false)
            allow(mock_nil).to receive(:!=).and_return(false)
            allow(mock_nil).to receive(:>).and_return(false)
            allow(mock_nil).to receive(:length).and_return(mock_nil)
            allow(mock_nil).to receive(:nil?).and_return(true)

            allow(@mock_row1).to receive(:text_field2).and_return('This is a text')
            allow(@mock_row2).to receive(:text_field2).and_return(mock_nil)
            allow(@mock_row3).to receive(:text_field2).and_return(mock_nil)
            allow(@mock_row4).to receive(:text_field2).and_return(mock_nil)
            allow(@mock_row5).to receive(:text_field2).and_return(mock_nil)
            allow(@mock_row6).to receive(:text_field2).and_return(mock_nil)

            @all_rows = [@mock_row1, @mock_row2, @mock_row3, @mock_row4, @mock_row5, @mock_row6]
            @table = Table.new(@path, @foreign_keys)
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

        it 'should return row 1 when filtering by text field 2 value not empty' do
            expect(@table.select('t.text_field2 != ""')).to eq([@mock_row1])
        end

        it 'should return row 1 when filtering by text field 2 matching value' do
            expect(@table.select('t.text_field2 == "This is a text"')).to eq([@mock_row1])
        end

        it 'should return row 1 when filtering by text field 2 with length > 2' do
            expect(@table.select('t.text_field2.length > 2')).to eq([@mock_row1])
        end
    end

    it 'should return call select when calling select_by_id with numeric id' do
        table = Table.new(@path, @foreign_keys)
        allow(table).to receive(:select)

        expect(table).to receive(:select).with('t._id == 3')
        table.select_by_id(3)
    end

    it 'should return call select when calling select_by_id with text id' do
        table = Table.new(@path, @foreign_keys)
        allow(table).to receive(:select)

        expect(table).to receive(:select).with('t._id == "XYZ"')
        table.select_by_id('"XYZ"')
    end
end
