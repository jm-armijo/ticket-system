class Result
    attr_reader :parent
    attr_reader :children

    def initialize(parent)
        @parent = parent
        @children = {}
    end

    def add_child(table, child)
        @children[table] = child
    end
end
