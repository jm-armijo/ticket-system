require_relative './nil_object'

class Row
    def initialize(data)
        @data = data
        @data&.transform_keys!(&:to_sym)
    end

private

    def method_missing(name)
        return NilObject.new if !respond_to_missing?(name)

        return @data[name.to_sym]
    end

    def respond_to_missing?(name)
        return @data.key?(name.to_sym)
    end
end
