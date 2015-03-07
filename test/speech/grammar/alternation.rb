require 'minitest/autorun'
require 'speech/grammar/alternation'

describe Speech::Grammar::Alternation do
    Alternation = Speech::Grammar::Alternation

    it 'must convert string arguments into atoms' do
	alternation = Alternation.new('one', 'two', 'three')
	alternation.elements.must_equal [Atom.new('one'), Atom.new('two'), Atom.new('three')]
    end

    it 'must be enumerable' do
	alternation = Alternation.new('one', 'two', 'three')
	alternation.all? {|a| a}
    end

    it 'must be mappable' do
	alternation = Alternation.new('one', 'two', 'three')
	i = 0
	alternation.map {|a| i = i + 1 }.must_equal [1,2,3]
    end
end
