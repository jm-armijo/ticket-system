require_relative './array_hash_iterator'

describe ArrayHashIterator do
    before(:each) do
        @dummy_class = Class.new do
            include ArrayHashIterator
        end
    end

    it 'should return empty when there are not foreign keys' do
        dummy = @dummy_class.new
        dummy.instance_variable_set(:@connections, [])

        values = []
        dummy.each { |t, f| values << [t, f] }

        expect(values).to eq([])
    end

    it 'should return pair when there is one foreign key' do
        dummy = @dummy_class.new
        dummy.instance_variable_set(:@connections, [{ table: 'table1', key: 'key1' }])

        values = []
        dummy.each { |t, f| values << [t, f] }

        expect(values).to eq([['table1', 'key1']])
    end

    it 'should return multiple pairs when there are multiple foreign keys' do
        dummy = @dummy_class.new
        connections = [{ table: 'table1', key: 'key1' }, { table: 'table2', key: 'key2' }]
        dummy.instance_variable_set(:@connections, connections)

        values = []
        dummy.each { |t, f| values << [t, f] }

        expect(values).to eq([['table1', 'key1'], ['table2', 'key2']])
    end
end
