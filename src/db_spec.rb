require 'diff/lcs'
require_relative './db'

describe DB do
    before(:each) do
        @path1 = 'this/is/a/path/to/table1.json'
        @path2 = 'this/is/a/path/to/table2.json'

        @foreign_keys_default = double
        @foreign_keys1 = double
        @foreign_keys2 = double

        @mock_table1 = double
        @mock_table2 = double
        allow(@mock_table1).to receive(:name).and_return('table1')
        allow(@mock_table2).to receive(:name).and_return('table2')

        allow(ForeignKeys).to receive(:new).and_return(@foreign_keys_default)
    end

    it 'should have 0 tables after initialization' do
        db = DB.new
        expect(db.instance_variable_get(:@tables).size).to be(0)
    end

    context 'when calling load_table_file' do
        it 'should create a table without foreign keys' do
            db = DB.new

            expect(Table).to receive(:new).with(@path1, @foreign_keys_default).and_return(@mock_table1)
            db.load_table_file(@path1)
        end

        it 'should create a table with foreign keys' do
            db = DB.new

            expect(Table).to receive(:new).with(@path1, @foreign_keys1).and_return(@mock_table1)
            db.load_table_file(@path1, @foreign_keys1)
        end

        it 'should have 1 tables after inserting a table' do
            db = DB.new

            allow(Table).to receive(:new).and_return(@mock_table1)
            db.load_table_file(@path1)

            expect(db.instance_variable_get(:@tables).size).to be(1)
        end

        it 'should store table by name after loading the file' do
            db = DB.new

            allow(Table).to receive(:new).and_return(@mock_table1)
            db.load_table_file(@path1)

            expect(db.instance_variable_get(:@tables).fetch(:table1)).to be(@mock_table1)
        end

        it 'should have 2 tables after inserting 2 tables' do
            db = DB.new

            allow(Table).to receive(:new).and_return(@mock_table1)
            db.load_table_file(@path1)

            allow(Table).to receive(:new).and_return(@mock_table2)
            db.load_table_file(@path2)

            expect(db.instance_variable_get(:@tables).size).to be(2)
        end

        it 'should store tables by name after loading the files' do
            db = DB.new

            allow(Table).to receive(:new).and_return(@mock_table1)
            db.load_table_file(@path1)

            allow(Table).to receive(:new).and_return(@mock_table2)
            db.load_table_file(@path2)

            expect(db.instance_variable_get(:@tables).keys).to eq(%i[table1 table2])
        end

        it 'should have 2 tables after overriding a table' do
            mock_new_table2 = double
            allow(mock_new_table2).to receive(:name).and_return('table2')

            db = DB.new

            allow(Table).to receive(:new).and_return(@mock_table1)
            db.load_table_file(@path1)

            allow(Table).to receive(:new).and_return(@mock_table2)
            db.load_table_file(@path2)

            allow(Table).to receive(:new).and_return(mock_new_table2)
            db.load_table_file(@path2)

            expect(db.instance_variable_get(:@tables).size).to be(2)
        end
    end

    context 'when calling execute' do
        it 'should execute select all query' do
            allow(@mock_table1).to receive(:select).and_return([])

            query = 'select from table1'
            db = DB.new
            db.instance_variable_set(:@tables, { table1: @mock_table1 })

            expect(@mock_table1).to receive(:select).with(nil)
            db.execute(query)
        end

        it 'should execute conditional select query' do
            allow(@mock_table1).to receive(:select).and_return([])

            condition = 't.condition > 1'
            query = "select from table1 where #{condition}"

            db = DB.new
            db.instance_variable_set(:@tables, { table1: @mock_table1 })

            expect(@mock_table1).to receive(:select).with(condition)
            db.execute(query)
        end

        it 'should not execute invalid query' do
            allow(@mock_table1).to receive(:select).and_return([])

            query = 'select from table1 please'
            db = DB.new
            db.instance_variable_set(:@tables, { table1: @mock_table1 })

            expect { db.execute(query) }.to output("Error: Invalid command `#{query}`.\n").to_stderr_from_any_process
        end

        it 'should remove additional queries and execute first' do
            allow(@mock_table1).to receive(:select).and_return([])

            hack = 'system("date")'
            condition = 't.condition > 1'
            query = "select from table1 where #{condition}; #{hack}"

            db = DB.new
            db.instance_variable_set(:@tables, { table1: @mock_table1 })

            expect(@mock_table1).to receive(:select).with(condition)
            expect(@mock_table1).not_to receive(:select)
            db.execute(query)
        end

        it 'should remove queries after the first and not execute invalid command' do
            allow(@mock_table1).to receive(:select).and_return([])

            hack = 'system("date")'
            condition = 't.condition > 1'
            query = "#{hack} ; select from table1 where #{condition}"

            db = DB.new
            db.instance_variable_set(:@tables, { table1: @mock_table1 })

            expect(@mock_table1).not_to receive(:select)
            expect { db.execute(query) }.to output("Error: Invalid command `#{hack}`.\n").to_stderr_from_any_process
        end

        it 'should get result when executing query' do
            row = double
            allow(@mock_table1).to receive(:select).and_return([row])
            allow(@mock_table1).to receive(:foreign_keys).and_return([])

            condition = 't.condition > 1'
            query = "select from table1 where #{condition}"

            db = DB.new
            db.instance_variable_set(:@tables, { table1: @mock_table1 })

            results = db.execute(query)
            expect(results.first.parent).to be(row)
        end

        it 'should get foreign key result when executing query' do
            row = double
            allow(row).to receive(:fk_id).and_return(3)

            foreign_keys = double
            allow(foreign_keys).to receive(:each).and_yield('table2', 'fk_id')

            allow(@mock_table1).to receive(:select).and_return([row])
            allow(@mock_table1).to receive(:foreign_keys).and_return(foreign_keys)

            mock_foreign_value = double
            allow(@mock_table2).to receive(:select_by_id).with(3).and_return(mock_foreign_value)

            condition = 't.condition > 1'
            query = "select from table1 where #{condition}"

            db = DB.new
            db.instance_variable_set(:@tables, { table1: @mock_table1, table2: @mock_table2 })

            results = db.execute(query)
            expect(results.first.children[:table2]).to eq(mock_foreign_value)
        end

        it 'should get multiple foreign key results when multiple foreign keys exist' do
            row = double
            allow(row).to receive(:fk_id2).and_return(3)
            allow(row).to receive(:fk_id3).and_return('a_key')

            foreign_keys1 = double
            allow(foreign_keys1).to receive(:each).and_yield('table2', 'fk_id2').and_yield('table3', 'fk_id3')

            allow(@mock_table1).to receive(:select).and_return([row])
            allow(@mock_table1).to receive(:foreign_keys).and_return(foreign_keys1)

            mock_foreign_value2 = double
            allow(@mock_table2).to receive(:select_by_id).with(3).and_return(mock_foreign_value2)

            mock_foreign_value3 = double
            @mock_table3 = double
            allow(@mock_table3).to receive(:name).and_return('table3')
            allow(@mock_table3).to receive(:select_by_id).with('a_key').and_return(mock_foreign_value3)

            condition = 't.condition > 1'
            query = "select from table1 where #{condition}"

            db = DB.new
            db.instance_variable_set(:@tables, { table1: @mock_table1, table2: @mock_table2, table3: @mock_table3 })

            results = db.execute(query)
            expect(results.first.children).to eq({ table2: mock_foreign_value2, table3: mock_foreign_value3 })
        end
    end
end
