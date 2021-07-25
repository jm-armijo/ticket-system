require_relative './result'

describe Result do
    before(:each) do
        @headers = %i[key1 key2]
        @values = [1, 'two']

        @row = double
        allow(@row).to receive(:headers).and_return(%i[key1 key2])
        allow(@row).to receive(:values).and_return(@values)
        allow(@row).to receive(:key1).and_return(1)
        allow(@row).to receive(:key2).and_return('two')
    end

    it 'should store the headers after initialization' do
        result = Result.new(@headers, @row)
        expect(result.headers).to eq(@headers)
    end

    it 'should store the values after initialization' do
        result = Result.new(@headers, @row)
        expect(result.values).to eq(@values)
    end

    it 'should add headers when add_columning rows' do
        rows = double
        allow(rows).to receive(:map).and_return([])

        result = Result.new(@headers, @row)
        result.instance_variable_set(:@headers, @headers)

        result.add_column(:key3, :new_key, rows)
        expect(result.headers).to eq(@headers + [:new_key])
    end

    it 'should add single value when calling add_column with a row' do
        mock_row = double
        allow(mock_row).to receive(:key3).and_return('value3')

        result = Result.new(@headers, @row)
        result.instance_variable_set(:@values, @values)

        result.add_column(:key3, :new_key, [mock_row])
        expect(result.values).to eq(@values + ['value3'])
    end

    it 'should add multiple values when calling add_columns with rows' do
        mock_row1 = double
        mock_row2 = double
        allow(mock_row1).to receive(:key3).and_return('valueX')
        allow(mock_row2).to receive(:key3).and_return('valueY')

        result = Result.new(@headers, @row)
        result.instance_variable_set(:@values, @values)

        result.add_column(:key3, :new_key, [mock_row1, mock_row2])
        expect(result.values).to eq(@values + ['valueX|valueY'])
    end

    it 'should remove headers when calling remove_column' do
        rows = double
        allow(rows).to receive(:map).and_return([])

        result = Result.new(@headers, @row)
        result.instance_variable_set(:@headers, @headers)

        result.remove_column(:key2)
        expect(result.headers).to eq([:key1])
    end

    it 'should remove value when calling remove_column' do
        mock_row = double
        allow(mock_row).to receive(:key3).and_return('value3')

        result = Result.new(@headers, @row)
        result.instance_variable_set(:@values, @values)

        result.remove_column(:key2)
        expect(result.values).to eq([1])
    end
end
