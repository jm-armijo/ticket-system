require_relative './nil_object'

class Row
    def initialize(data)
        @data = data
        @data&.transform_keys!(&:to_sym)
    end

    def id
        return _id
    end

    def headers
        return @data.keys
    end

    def values(headers)
        return headers.map do |header|
            @data.key?(header) ? @data[header] : NilObject.new
        end
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
