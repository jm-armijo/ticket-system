require 'diff/lcs'
require_relative './db'

describe DB do
    it 'should have 0 tables after initialization' do
        db = DB.new
        expect(db.instance_variable_get(:@tables).size).to be(0)
    end

    it 'should have 1 tables after inserting a table' do
        mock_table = double
        allow(mock_table).to receive(:name).and_return('table1')

        db = DB.new
        db.add_table(mock_table)
        expect(db.instance_variable_get(:@tables).size).to be(1)
    end

    it 'should have 2 tables after inserting 2 tables' do
        mock_table1 = double
        mock_table2 = double
        allow(mock_table1).to receive(:name).and_return('table1')
        allow(mock_table2).to receive(:name).and_return('table2')

        db = DB.new
        db.add_table(mock_table1)
        db.add_table(mock_table2)
        expect(db.instance_variable_get(:@tables).size).to be(2)
    end

    it 'should have 2 tables after overriding a table' do
        mock_table1 = double
        mock_table2 = double
        mock_new_table2 = double
        allow(mock_table1).to receive(:name).and_return('table1')
        allow(mock_table2).to receive(:name).and_return('table2')
        allow(mock_new_table2).to receive(:name).and_return('table2')

        db = DB.new
        db.add_table(mock_table1)
        db.add_table(mock_table2)
        db.add_table(mock_new_table2)
        expect(db.instance_variable_get(:@tables).size).to be(2)
    end

    it 'should execute select all query' do
        mock_table = double
        allow(mock_table).to receive(:select).and_return([])

        query = 'select from table1'
        db = DB.new
        db.instance_variable_set(:@tables, { table1: mock_table })

        expect(mock_table).to receive(:select).with(nil)
        db.execute(query)
    end

    it 'should execute conditional select query' do
        mock_table = double
        allow(mock_table).to receive(:select).and_return([])

        condition = 't.condition > 1'
        query = "select from table1 where #{condition}"

        db = DB.new
        db.instance_variable_set(:@tables, { table1: mock_table })

        expect(mock_table).to receive(:select).with(condition)
        db.execute(query)
    end

    it 'should not execute invalid query' do
        mock_table = double
        allow(mock_table).to receive(:select).and_return([])

        query = 'select from table1 please'
        db = DB.new
        db.instance_variable_set(:@tables, { table1: mock_table })

        expect(mock_table).not_to receive(:select)
        expect { db.execute(query) }.to output("Error: Invalid command `#{query}`.\n").to_stderr_from_any_process
    end

    it 'should remove queries additional queries and execute first' do
        mock_table = double
        allow(mock_table).to receive(:select).and_return([])

        hack = 'system("date")'
        condition = 't.condition > 1'
        query = "select from table1 where #{condition}; #{hack}"

        db = DB.new
        db.instance_variable_set(:@tables, { table1: mock_table })

        expect(mock_table).to receive(:select).with(condition)
        expect(mock_table).not_to receive(:select)
        db.execute(query)
    end

    it 'should remove queries after the first and not execute invalid command' do
        mock_table = double
        allow(mock_table).to receive(:select).and_return([])

        hack = 'system("date")'
        condition = 't.condition > 1'
        query = "#{hack} ; select from table1 where #{condition}"

        db = DB.new
        db.instance_variable_set(:@tables, { table1: mock_table })

        expect(mock_table).not_to receive(:select)
        expect { db.execute(query) }.to output("Error: Invalid command `#{hack}`.\n").to_stderr_from_any_process
    end
end
