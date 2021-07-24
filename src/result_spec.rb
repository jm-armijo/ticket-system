require_relative './result'

describe Result do
    it 'should store the parent after initialization' do
        parent_result = double
        result = Result.new(parent_result)
        expect(result.parent).to be(parent_result)
    end

    it 'should have no children after initialization' do
        parent_result = double
        result = Result.new(parent_result)
        expect(result.children.length).to be(0)
    end

    it 'should have one child when adding one' do
        result = Result.new(double)

        result.add_child(double, double)
        expect(result.children.length).to be(1)
    end

    it 'should have given child when adding one' do
        child_table = 'table1'
        child_result = double

        result = Result.new(double)

        result.add_child(child_table, child_result)
        expect(result.children[child_table]).to be(child_result)
    end

    it 'should have three children when adding three' do
        result = Result.new(double)

        result.add_child(double, double)
        result.add_child(double, double)
        result.add_child(double, double)
        expect(result.children.length).to be(3)
    end

    it 'should override child when two added for same table' do
        child_table = 'table1'
        child_result1 = double
        child_result2 = double

        result = Result.new(double)

        result.add_child(child_table, child_result1)
        result.add_child(child_table, child_result2)
        expect(result.children[child_table]).to be(child_result2)
    end
end
