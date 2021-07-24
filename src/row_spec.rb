require 'diff/lcs'
require_relative './row'

describe Row do
    it 'should save data on initialization' do
        mock_data = double
        allow(mock_data).to receive(:transform_keys!)

        row = Row.new(mock_data)
        expect(row.instance_variable_get(:@data)).to equal(mock_data)
    end

    it 'should save data on initialization even if it is nil' do
        row = Row.new(nil)
        expect(row.instance_variable_get(:@data)).to be_nil
    end

    it 'should save keys as symbols when passed as symbols' do
        data = { key1: 'value1', key2: 'value2' }
        row = Row.new(data)
        expect(row.instance_variable_get(:@data).keys.all? { |k| k.is_a?(Symbol) }).to be(true)
    end

    it 'should save keys as symbols when passed as strings' do
        data = { key1: 'value1', key2: 'value2' }
        row = Row.new(data)
        expect(row.instance_variable_get(:@data).keys.all? { |k| k.is_a?(Symbol) }).to be(true)
    end

    it 'should give access to key given as symbol' do
        data = { key1: 'value1', key2: 'value2' }
        row = Row.new(data)

        expect(row.key1).to eq('value1')
    end

    it 'should give access to key given as string' do
        data = { 'key1' => 'value1', 'key2' => 'value2' }
        row = Row.new(data)

        expect(row.key1).to eq('value1')
    end

    it 'should give access to headers' do
        data = { 'key1' => 'value1', 'key2' => 'value2' }
        row = Row.new(data)

        expect(row.headers).to eq(%i[key1 key2])
    end
end
