class NilObject
    def nil?
        return true
    end

    def zero?
        return false
    end

    def positive?
        return false
    end

    def negative?
        return false
    end

    def eq?(other)
        return other.instance_of?(NilObject)
    end

    def ==(other)
        return other.nil?
    end

    def !=(other)
        return !other.nil?
    end

    def <=>(other)
        return 0 if other.nil?

        return nil
    end

    def >(_other)
        return false
    end

    def >=(other)
        return other.nil?
    end

    def <(_other)
        return false
    end

    def <=(other)
        return other.nil?
    end

    def to_a
        return [nil]
    end

    def to_ary
        return to_a
    end

private

    def method_missing(_name, *_args, &_block)
        return NilObject.new
    end

    def respond_to_missing?(_name, *_args)
        return true
    end
end
