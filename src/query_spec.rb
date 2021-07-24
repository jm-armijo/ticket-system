require_relative './query'

describe Query do
    it 'should extract table from query on initialization' do
        query = Query.new('select * from table1')
        expect(query.table).to eq(:table1)
    end

    it 'should have nil conditions from unconditional query on initialization' do
        query = Query.new('select * from table1')
        expect(query.conditions).to be_nil
    end

    it 'should extract table from conditioanl query on initialization' do
        query = Query.new('select * from table1 where value == 1')
        expect(query.table).to eq(:table1)
    end

    it 'should extract conditions from conditional query on initialization' do
        query = Query.new('select * from table1 where value == 1')
        expect(query.conditions).to eq('value == 1')
    end

    it 'should extract table when query has extra space characters' do
        query = Query.new("  \t   select * from table1\n   ")
        expect(query.table).to eq(:table1)
    end

    it 'should extract conditions when query has extra space characters' do
        query = Query.new("  \t   select * from table1 where value == 1\n   ")
        expect(query.conditions).to eq('value == 1')
    end

    it 'should inform when original query is truncated' do
        expected_message = "Warning: The query was truncated.\n"
        query_string = 'select * from table1 ; select * from table2'
        expect { Query.new(query_string) }.to output(expected_message).to_stderr_from_any_process
    end

    it 'should extract first table when query is truncated' do
        expected_message = "Warning: The query was truncated.\n"
        query_string = 'select * from table1 where value == 1; select * from table2 where value = 2'

        query = nil
        expect { query = Query.new(query_string) }.to output(expected_message).to_stderr_from_any_process
        expect(query.table).to eq(:table1)
    end

    it 'should extract first condition when query is truncated' do
        expected_message = "Warning: The query was truncated.\n"
        query_string = 'select * from table1 where value == 1; select * from table2 where value = 2'

        query = nil
        expect { query = Query.new(query_string) }.to output(expected_message).to_stderr_from_any_process
        expect(query.conditions).to eq('value == 1')
    end

    it 'should error when query is invalid' do
        hack = 'system("date")'
        expected_message = "Error: Invalid command `#{hack}`.\n"
        expect { Query.new(hack) }.to output(expected_message).to_stderr_from_any_process
    end

    it 'should have nil table when query is invalid' do
        hack = 'system("date")'
        expected_message = "Error: Invalid command `#{hack}`.\n"

        query = nil
        expect { query = Query.new(hack) }.to output(expected_message).to_stderr_from_any_process
        expect(query.table).to be_nil
    end

    it 'should have nil conditions when query is invalid' do
        hack = 'system("date")'
        expected_message = "Error: Invalid command `#{hack}`.\n"

        query = nil
        expect { query = Query.new(hack) }.to output(expected_message).to_stderr_from_any_process
        expect(query.conditions).to be_nil
    end

    it 'should error when truncated query is invalid' do
        hack = 'system("date")'
        query_string = "#{hack} ; select * from table1 where value == 1"

        expected_truncate_message = "Warning: The query was truncated.\n"
        expected_error_message = "Error: Invalid command `#{hack}`.\n"
        expected_message = expected_truncate_message + expected_error_message

        expect { Query.new(query_string) }.to output(expected_message).to_stderr_from_any_process
    end

    it 'should have nil table when truncated query is invalid' do
        hack = 'system("date")'
        query_string = "#{hack} ; select * from table1 where value == 1"

        expected_truncate_message = "Warning: The query was truncated.\n"
        expected_error_message = "Error: Invalid command `#{hack}`.\n"
        expected_message = expected_truncate_message + expected_error_message

        query = nil
        expect { query = Query.new(query_string) }.to output(expected_message).to_stderr_from_any_process
        expect(query.table).to be_nil
    end

    it 'should have nil conditions when truncated query is invalid' do
        hack = 'system("date")'
        query_string = "#{hack} ; select * from table1 where value == 1"

        expected_truncate_message = "Warning: The query was truncated.\n"
        expected_error_message = "Error: Invalid command `#{hack}`.\n"
        expected_message = expected_truncate_message + expected_error_message

        query = nil
        expect { query = Query.new(query_string) }.to output(expected_message).to_stderr_from_any_process
        expect(query.conditions).to be_nil
    end

    it 'should not error when truncated query is valid' do
        hack = 'system("date")'
        query_string = "select * from table1 where value == 1 ; #{hack}"

        expected_message = "Warning: The query was truncated.\n"
        expect { Query.new(query_string) }.to output(expected_message).to_stderr_from_any_process
    end
end
