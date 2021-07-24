require_relative './result'

describe Result do
    before(:each) do
        @parent_result = double
        allow(@parent_result).to receive(:headers).and_return(%i[key1 key2])
        allow(@parent_result).to receive(:key1).and_return(1)
        allow(@parent_result).to receive(:key2).and_return('two')

        @child_result1 = double
        allow(@child_result1).to receive(:headers).and_return(%i[key3 key4])
        allow(@child_result1).to receive(:key3).and_return('three.1')
        allow(@child_result1).to receive(:key4).and_return(4.1)

        @child_result2 = double
        allow(@child_result2).to receive(:headers).and_return(%i[key3 key4])
        allow(@child_result2).to receive(:key3).and_return('three.2')
        allow(@child_result2).to receive(:key4).and_return(4.2)
    end

    it 'should store the parent after initialization' do
        result = Result.new(@parent_result)
        expect(result.parent).to eq({ headers: %i[key1 key2], values: [[1, 'two']] })
    end

    it 'should have no children after initialization' do
        result = Result.new(@parent_result)
        expect(result.children.length).to be(0)
    end

    it 'should have one child when adding one' do
        child_table = 'table1'
        result = Result.new(@parent_result)

        result.add_child(child_table, [@child_result1])
        expect(result.children.length).to be(1)
    end

    it 'should have given child when adding one' do
        child_table = 'table1'
        result = Result.new(@parent_result)

        result.add_child(child_table, [@child_result1])
        expect(result.children[child_table]).to eq({ headers: %i[key3 key4], values: [['three.1', 4.1]] })
    end

    it 'should have three children when adding three' do
        result = Result.new(@parent_result)

        result.add_child(double, [@child_result1])
        result.add_child(double, [@child_result2])
        result.add_child(double, [@child_result2])
        expect(result.children.length).to be(3)
    end

    it 'should override child when two added for same table' do
        child_table = 'table1'
        result = Result.new(@parent_result)

        result.add_child(child_table, [@child_result1])
        result.add_child(child_table, [@child_result2])
        expect(result.children[child_table]).to eq({ headers: %i[key3 key4], values: [['three.2', 4.2]] })
    end
end
