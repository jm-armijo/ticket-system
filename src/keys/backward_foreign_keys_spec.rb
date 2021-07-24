require_relative './backward_foreign_keys'

describe BackwardForeignKeys do
    it 'should have 0 elements before pushing' do
        backward_keys = BackwardForeignKeys.new

        num_keys = backward_keys.instance_variable_get(:@connections).length
        expect(num_keys).to be(0)
    end

    context 'on push elements' do
        before(:each) do
            @key1 = double
            @key2 = double
            @key3 = double
        end

        it 'should have one element when pushing one' do
            backward_keys = BackwardForeignKeys.new
            backward_keys << @key1

            num_keys = backward_keys.instance_variable_get(:@connections).length
            expect(num_keys).to be(1)
        end

        it 'should have three elements when pushing three' do
            backward_keys = BackwardForeignKeys.new
            backward_keys << @key1
            backward_keys << @key2
            backward_keys << @key3

            num_keys = backward_keys.instance_variable_get(:@connections).length
            expect(num_keys).to be(3)
        end

        it 'should have three elements when pushing three' do
            backward_keys = BackwardForeignKeys.new
            backward_keys << @key1
            backward_keys << @key2
            backward_keys << @key3

            keys = backward_keys.instance_variable_get(:@connections)
            expect(keys).to eq([@key1, @key2, @key3])
        end
    end

    context 'on calling each' do
        it 'should return empty when there are not foreign keys' do
            backward_keys = BackwardForeignKeys.new

            values = []
            backward_keys.each { |t, f| values << [t, f] }

            expect(values).to eq([])
        end

        it 'should return pair when there is one foreign key' do
            backward_keys = BackwardForeignKeys.new
            backward_keys.instance_variable_set(:@connections, [{ table: 'table1', key: 'key1' }])

            values = []
            backward_keys.each { |t, f| values << [t, f] }

            expect(values).to eq([['table1', 'key1']])
        end

        it 'should return multiple pairs when there are multiple foreign keys' do
            connections = [{ table: 'table1', key: 'key1' }, { table: 'table2', key: 'key2' }]
            backward_keys = BackwardForeignKeys.new
            backward_keys.instance_variable_set(:@connections, connections)

            values = []
            backward_keys.each { |t, f| values << [t, f] }

            expect(values).to eq([['table1', 'key1'], ['table2', 'key2']])
        end
    end
end
