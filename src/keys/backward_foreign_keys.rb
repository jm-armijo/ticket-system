require 'forwardable'
require_relative './array_hash_iterator'

class BackwardForeignKeys
    extend Forwardable
    def_delegator :@connections, :<<

    include ArrayHashIterator

    def initialize
        @connections = []
    end
end
