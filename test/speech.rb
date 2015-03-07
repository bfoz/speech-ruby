require 'minitest/autorun'
require 'speech'

describe Speech do
    it 'must have a module method for building a grammar' do
	Speech.grammar do
	    rule rule1: 'one' do
	    end
	end
    end
end
