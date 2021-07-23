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
            foreign_keys.each { |t,f| values << [t,f] }

            expect(values).to eq([])
        end

        it 'should return pair when there is one foreign key' do
            json_keys = '[{"table" : "table1", "key": "key1"}]'
            foreign_keys = ForeignKeys.new(json_keys)

            values = []
            foreign_keys.each { |t,f| values << [t,f] }

            expect(values).to eq([['table1','key1']])
        end

        it 'should return multiple pairs when there are multiple foreign keys' do
            json_keys = '[{"table" : "table1", "key": "key1"}, {"table" : "table2", "key": "key2"}]'
            foreign_keys = ForeignKeys.new(json_keys)

            values = []
            foreign_keys.each { |t,f| values << [t,f] }

            expect(values).to eq([['table1','key1'], ['table2','key2']])
        end
    end
end
