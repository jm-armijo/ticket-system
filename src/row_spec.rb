require 'diff/lcs'
require_relative './row'

describe Row do
    it 'should save data on initialization' do
        mock_data = double
        row = Row.new(mock_data)
        expect(row.instance_variable_get(:@data)).to equal(mock_data)
    end

    it 'should save data on initialization even if it is nil' do
        row = Row.new(nil)
        expect(row.instance_variable_get(:@data)).to be_nil
    end
end
