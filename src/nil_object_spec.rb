require 'diff/lcs'
require_relative './nil_object'

describe NilObject do
    it 'should be nil' do
        nil_object = NilObject.new
        expect(nil_object.nil?).to be(true)
    end

    context 'when using the == operator' do
        it 'should return true when compared to nil' do
            nil_object = NilObject.new
            expect(nil_object == nil).to be(true) # rubocop:disable Style/NilComparison
        end

        it 'should return true when compared to another NilObject' do
            nil_object = NilObject.new
            expect(nil_object == NilObject.new).to be(true)
        end

        it 'should return false when compared to empty string' do
            nil_object = NilObject.new
            expect(nil_object == '').to be(false)
        end

        it 'should return false when compared to number 0' do
            nil_object = NilObject.new
            expect(nil_object == 0).to be(false) # rubocop:disable Style/NumericPredicate
        end
    end

    context 'when using the != operator' do
        it 'should return false when compared to nil' do
            nil_object = NilObject.new
            expect(nil_object != nil).to be(false) # rubocop:disable Style/NonNilCheck
        end

        it 'should return false when compared to another NilObject' do
            nil_object = NilObject.new
            expect(nil_object != NilObject.new).to be(false)
        end

        it 'should return true when compared to empty string' do
            nil_object = NilObject.new
            expect(nil_object != '').to be(true)
        end

        it 'should return true when compared to number 0' do
            nil_object = NilObject.new
            expect(nil_object != 0).to be(true)
        end
    end

    context 'when using the <=> operator' do
        it 'should return 0 when compared to nil' do
            nil_object = NilObject.new
            expect(nil_object <=> nil).to be(0)
        end

        it 'should return false when compared to another NilObject' do
            nil_object = NilObject.new
            expect(nil_object <=> NilObject.new).to be(0)
        end

        it 'should return nil when compared to empty string' do
            nil_object = NilObject.new
            expect(nil_object <=> '').to be_nil
        end

        it 'should return nil when compared to number 0' do
            nil_object = NilObject.new
            expect(nil_object <=> 0).to be_nil
        end
    end

    context 'when using the eq? operator' do
        it 'should return false when compared to nil' do
            nil_object = NilObject.new
            expect(nil_object.eq?(nil)).to be(false)
        end

        it 'should return false when compared to another NilObject' do
            nil_object = NilObject.new
            expect(nil_object.eq?(NilObject.new)).to be(true)
        end

        it 'should return nil when compared to empty string' do
            nil_object = NilObject.new
            expect(nil_object.eq?('')).to be(false)
        end

        it 'should return nil when compared to number 0' do
            nil_object = NilObject.new
            expect(nil_object.eq?(0)).to be(false)
        end
    end

    context 'when using the > operator' do
        it 'should return false when compared to nil' do
            nil_object = NilObject.new
            expect(nil_object > nil).to be(false)
        end

        it 'should return false when compared to another NilObject' do
            nil_object = NilObject.new
            expect(nil_object > NilObject.new).to be(false)
        end

        it 'should return false when compared to empty string' do
            nil_object = NilObject.new
            expect(nil_object > '').to be(false)
        end

        it 'should return false when compared to number 0' do
            nil_object = NilObject.new
            expect(nil_object > 0).to be(false) # rubocop:disable Style/NumericPredicate
        end
    end

    context 'when using the >= operator' do
        it 'should return true when compared to nil' do
            nil_object = NilObject.new
            expect(nil_object >= nil).to be(true)
        end

        it 'should return true when compared to another NilObject' do
            nil_object = NilObject.new
            expect(nil_object >= NilObject.new).to be(true)
        end

        it 'should return false when compared to empty string' do
            nil_object = NilObject.new
            expect(nil_object >= '').to be(false)
        end

        it 'should return false when compared to number 0' do
            nil_object = NilObject.new
            expect(nil_object >= 0).to be(false)
        end
    end

    context 'when using the < operator' do
        it 'should return false when compared to nil' do
            nil_object = NilObject.new
            expect(nil_object < nil).to be(false)
        end

        it 'should return false when compared to another NilObject' do
            nil_object = NilObject.new
            expect(nil_object < NilObject.new).to be(false)
        end

        it 'should return false when compared to empty string' do
            nil_object = NilObject.new
            expect(nil_object < '').to be(false)
        end

        it 'should return false when compared to number 0' do
            nil_object = NilObject.new
            expect(nil_object < 0).to be(false) # rubocop:disable Style/NumericPredicate
        end
    end

    context 'when using the <= operator' do
        it 'should return true when compared to nil' do
            nil_object = NilObject.new
            expect(nil_object <= nil).to be(true)
        end

        it 'should return true when compared to another NilObject' do
            nil_object = NilObject.new
            expect(nil_object <= NilObject.new).to be(true)
        end

        it 'should return false when compared to empty string' do
            nil_object = NilObject.new
            expect(nil_object <= '').to be(false)
        end

        it 'should return false when compared to number 0' do
            nil_object = NilObject.new
            expect(nil_object <= 0).to be(false)
        end
    end

    it 'should return NilObject when undefined method called' do
        nil_object = NilObject.new
        response = nil_object.this_method_is_undefined
        expect(response).to be_instance_of(NilObject)
    end

    it 'should return true when compared to nil using nil?' do
        nil_object = NilObject.new
        expect(nil_object.nil?).to be(true)
    end

    it 'should return false when compared to number 0 using zero?' do
        nil_object = NilObject.new
        expect(nil_object.zero?).to be(false)
    end

    it 'should return false when compared to nil using !x.nil?' do
        nil_object = NilObject.new
        expect(!nil_object.nil?).to be(false)
    end

    it 'should return false when compared to number 0 using positive?' do
        nil_object = NilObject.new
        expect(nil_object.positive?).to be(false)
    end

    it 'should return false when compared to number 0 using negative?' do
        nil_object = NilObject.new
        expect(nil_object.negative?).to be(false)
    end
end
