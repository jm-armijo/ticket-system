require_relative './foreign_keys'

describe ForeignKeys do
    context 'on initialization' do
        it 'should raise error when foreign keys format is invalid' do
            foreign_keys = '[xxxxx]'
            expect { ForeignKeys.new(foreign_keys) }.to raise_error(JSON::Schema::ValidationError)
        end

        it 'should raise error when foreign keys is not a JSON array' do
            foreign_keys = '{"key": "value"}'
            expect { ForeignKeys.new(foreign_keys) }.to raise_error(JSON::Schema::ValidationError)
        end

        it 'should raise error when foreign keys do not have the "table" field' do
            foreign_keys = '[{"key": "value"}]'
            expect { ForeignKeys.new(foreign_keys) }.to raise_error(JSON::Schema::ValidationError)
        end

        it 'should raise error when foreign keys do not have the "key" field' do
            foreign_keys = '[{"table": "value"}]'
            expect { ForeignKeys.new(foreign_keys) }.to raise_error(JSON::Schema::ValidationError)
        end

        it 'should raise error when foreign keys include unexpected field' do
            foreign_keys = '[{"table": "t", "key": "k", "fake": "f"}]'
            expect { ForeignKeys.new(foreign_keys) }.to raise_error(JSON::Schema::ValidationError)
        end
    end

    context 'on calling each' do
        it 'should return empty when there are not foreign keys' do
            json_keys = '[]'
            foreign_keys = ForeignKeys.new(json_keys)

            values = []
            foreign_keys.each { |t, f| values << [t, f] }

            expect(values).to eq([])
        end

        it 'should return pair when there is one foreign key' do
            json_keys = '[{"table" : "table1", "key": "key1"}]'
            foreign_keys = ForeignKeys.new(json_keys)

            values = []
            foreign_keys.each { |t, f| values << [t, f] }

            expect(values).to eq([['table1', 'key1']])
        end

        it 'should return multiple pairs when there are multiple foreign keys' do
            json_keys = '[{"table" : "table1", "key": "key1"}, {"table" : "table2", "key": "key2"}]'
            foreign_keys = ForeignKeys.new(json_keys)

            values = []
            foreign_keys.each { |t, f| values << [t, f] }

            expect(values).to eq([['table1', 'key1'], ['table2', 'key2']])
        end
    end

    context 'on calling get_backward_keys' do
        before(:each) do
            @parent_name = 'parent_table'

            @mock_backward_keys1 = double
            @mock_backward_keys2 = double
            allow(BackwardForeignKeys).to receive(:new).and_return(@mock_backward_keys1, @mock_backward_keys2)
        end

        it 'should return empty when there are not foreign keys' do
            json_keys = '[]'
            foreign_keys = ForeignKeys.new(json_keys)

            expect(foreign_keys.get_backward_keys(@parent_name)).to eq({})
        end

        it 'should add backward keys when there is a foreign key' do
            json_keys = '[{"table" : "table1", "key": "key1"}]'
            foreign_keys = ForeignKeys.new(json_keys)

            expect(@mock_backward_keys1).to receive(:<<).once.with({ table: @parent_name, key: 'key1' })
            foreign_keys.get_backward_keys(@parent_name)
        end

        it 'should add backward keys when there are foreign keys' do
            json_keys = '[{"table" : "table1", "key": "key1"}, {"table" : "table2", "key": "key2"}]'
            foreign_keys = ForeignKeys.new(json_keys)

            expect(@mock_backward_keys1).to receive(:<<).once.with({ table: @parent_name, key: 'key1' })
            expect(@mock_backward_keys2).to receive(:<<).once.with({ table: @parent_name, key: 'key2' })
            foreign_keys.get_backward_keys(@parent_name)
        end

        it 'should save backward keys by name when there are foreign keys' do
            allow(@mock_backward_keys1).to receive(:<<).once.with({ table: @parent_name, key: 'key1' })
            allow(@mock_backward_keys2).to receive(:<<).once.with({ table: @parent_name, key: 'key2' })

            json_keys = '[{"table" : "table1", "key": "key1"}, {"table" : "table2", "key": "key2"}]'
            foreign_keys = ForeignKeys.new(json_keys)

            backward_keys = foreign_keys.get_backward_keys(@parent_name)
            expect(backward_keys).to eq({ table1: @mock_backward_keys1, table2: @mock_backward_keys2 })
        end
    end
end
