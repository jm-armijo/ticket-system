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

    it 'should access the overrider table' do
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
        expect(db.table2).to equal(mock_new_table2)
    end

    it 'should give access to the first table whem 2 added' do
        mock_table1 = double
        mock_table2 = double
        allow(mock_table1).to receive(:name).and_return('table1')
        allow(mock_table2).to receive(:name).and_return('table2')

        db = DB.new
        db.add_table(mock_table1)
        db.add_table(mock_table2)
        expect(db.table1).to equal(mock_table1)
    end

    it 'should give access to the last table whem 2 added' do
        mock_table1 = double
        mock_table2 = double
        allow(mock_table1).to receive(:name).and_return('table1')
        allow(mock_table2).to receive(:name).and_return('table2')

        db = DB.new
        db.add_table(mock_table1)
        db.add_table(mock_table2)
        expect(db.table2).to equal(mock_table2)
    end
end
