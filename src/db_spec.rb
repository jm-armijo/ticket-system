require 'diff/lcs'
require_relative './db'

describe DB do
    before(:each) do
        @path1 = 'this/is/a/path/to/table1.json'
        @path2 = 'this/is/a/path/to/table2.json'

        @foreign_keys1 = double
        @foreign_keys2 = double

        allow(@foreign_keys1).to receive(:get_backward_keys).and_return([])
        allow(@foreign_keys2).to receive(:get_backward_keys).and_return([])

        @mock_table1 = double
        @mock_table2 = double

        allow(@mock_table1).to receive(:name).and_return(:table1)
        allow(@mock_table2).to receive(:name).and_return(:table2)

        allow(@mock_table1).to receive(:foreign_keys).and_return(@foreign_keys1)
        allow(@mock_table2).to receive(:foreign_keys).and_return(@foreign_keys2)
    end

    it 'should have 0 tables after initialization' do
        db = DB.new
        expect(db.instance_variable_get(:@tables).size).to be(0)
    end

    context 'when calling load_table_file' do
        it 'should create a table without foreign keys' do
            db = DB.new

            expect(Table).to receive(:new).with(@path1, @foreign_keys1).and_return(@mock_table1)
            db.load_table_file(@path1, @foreign_keys1)
        end

        it 'should create a table with foreign keys' do
            db = DB.new

            expect(Table).to receive(:new).with(@path1, @foreign_keys1).and_return(@mock_table1)
            db.load_table_file(@path1, @foreign_keys1)
        end

        it 'should have 1 tables after inserting a table' do
            db = DB.new

            allow(Table).to receive(:new).and_return(@mock_table1)
            db.load_table_file(@path1, @foreign_keys1)

            expect(db.instance_variable_get(:@tables).size).to be(1)
        end

        it 'should store table by name after loading the file' do
            db = DB.new

            allow(Table).to receive(:new).and_return(@mock_table1)
            db.load_table_file(@path1, @foreign_keys1)

            expect(db.instance_variable_get(:@tables).fetch(:table1)).to be(@mock_table1)
        end

        it 'should have 2 tables after inserting 2 tables' do
            db = DB.new

            allow(Table).to receive(:new).and_return(@mock_table1)
            db.load_table_file(@path1, @foreign_keys1)

            allow(Table).to receive(:new).and_return(@mock_table2)
            db.load_table_file(@path2, @foreign_keys2)

            expect(db.instance_variable_get(:@tables).size).to be(2)
        end

        it 'should store tables by name after loading the files' do
            db = DB.new

            allow(Table).to receive(:new).and_return(@mock_table1)
            db.load_table_file(@path1, @foreign_keys1)

            allow(Table).to receive(:new).and_return(@mock_table2)
            db.load_table_file(@path2, @foreign_keys2)

            expect(db.instance_variable_get(:@tables).keys).to eq(%i[table1 table2])
        end

        it 'should have 2 tables after overriding a table' do
            mock_new_table2 = double
            mock_foreign_keys2 = double
            allow(mock_foreign_keys2).to receive(:get_backward_keys).and_return([])
            allow(mock_new_table2).to receive(:name).and_return('table2')
            allow(mock_new_table2).to receive(:foreign_keys).and_return(mock_foreign_keys2)

            db = DB.new

            allow(Table).to receive(:new).and_return(@mock_table1)
            db.load_table_file(@path1, @foreign_keys1)

            allow(Table).to receive(:new).and_return(@mock_table2)
            db.load_table_file(@path2, @foreign_keys2)

            allow(Table).to receive(:new).and_return(mock_new_table2)
            db.load_table_file(@path2, @foreign_keys2)

            expect(db.instance_variable_get(:@tables).size).to be(2)
        end
    end

    context 'when calling execute' do
        before(:each) do
            @row = double
            allow(@row).to receive(:fk_id2).and_return(3)
            allow(@row).to receive(:fk_id3).and_return('a_key')

            @foreign_keys1 = double
            allow(@foreign_keys1).to receive(:each).and_yield('table2', 'fk_id2').and_yield('table3', 'fk_id3')

            allow(@mock_table1).to receive(:select).and_return([])
            allow(@mock_table1).to receive(:foreign_keys).and_return(@foreign_keys1)
            allow(@mock_table1).to receive(:backward_keys).and_return([])

            @mock_foreign_value2 = double
            allow(@mock_table2).to receive(:select_by_id).with(3).and_return(@mock_foreign_value2)

            @mock_foreign_value3 = double
            @mock_table3 = double
            allow(@mock_table3).to receive(:name).and_return('table3')
            allow(@mock_table3).to receive(:select_by_id).with('a_key').and_return(@mock_foreign_value3)

            @query_with_conditions = double
            allow(@query_with_conditions).to receive(:table).and_return(:table1)
            allow(@query_with_conditions).to receive(:conditions).and_return('value > 1')

            @query_without_conditions = double
            allow(@query_without_conditions).to receive(:table).and_return(:table1)
            allow(@query_without_conditions).to receive(:conditions).and_return(nil)
        end

        it 'should execute select all query' do
            db = DB.new
            db.instance_variable_set(:@tables, { table1: @mock_table1 })

            expect(@mock_table1).to receive(:select).with(nil)
            db.execute(@query_without_conditions)
        end

        it 'should execute conditional select query' do
            db = DB.new
            db.instance_variable_set(:@tables, { table1: @mock_table1 })

            expect(@mock_table1).to receive(:select).with('value > 1')
            db.execute(@query_with_conditions)
        end

        it 'should get result when executing query' do
            allow(@mock_table1).to receive(:select).and_return([@row])
            allow(@mock_table1).to receive(:foreign_keys).and_return([])

            db = DB.new
            db.instance_variable_set(:@tables, { table1: @mock_table1 })

            results = db.execute(@query_with_conditions)
            expect(results.first.parent).to be(@row)
        end

        it 'should add foreign key child when executing query' do
            mock_result = double
            allow(mock_result).to receive(:add_child)
            allow(Result).to receive(:new).and_return(mock_result)

            allow(@foreign_keys1).to receive(:map).and_return([{ table: :table2, my_key: 'fk_id2', other_key: 'id' }])
            allow(@mock_table1).to receive(:select).and_return([@row])
            allow(@mock_table2).to receive(:select).and_return([@mock_foreign_value2])

            db = DB.new
            db.instance_variable_set(:@tables, { table1: @mock_table1, table2: @mock_table2 })

            expect(mock_result).to receive(:add_child).with(:table1, [@mock_foreign_value2])
            db.execute(@query_with_conditions)
        end

        it 'should add backward foreign key child when executing query' do
            allow(@row).to receive(:id).and_return('id_value')

            mock_result = double
            allow(mock_result).to receive(:add_child)
            allow(Result).to receive(:new).and_return(mock_result)

            @backward_keys1 = double
            allow(@backward_keys1).to receive(:each).and_yield('table2', 'fk_id2')
            allow(@backward_keys1).to receive(:map).and_return([{ table: :table2, my_key: 'id', other_key: 'fk_id2' }])

            allow(@mock_table1).to receive(:select).and_return([@row])
            allow(@mock_table1).to receive(:foreign_keys).and_return([])
            allow(@mock_table1).to receive(:backward_keys).and_return(@backward_keys1)

            allow(@mock_table2).to receive(:select).and_return([@mock_foreign_value2])

            db = DB.new
            db.instance_variable_set(:@tables, { table1: @mock_table1, table2: @mock_table2 })

            expect(mock_result).to receive(:add_child).with(:table1, [@mock_foreign_value2])
            db.execute(@query_with_conditions)
        end
    end
end
