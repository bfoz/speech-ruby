require 'minitest/autorun'
require 'speech/grammar/atom'

describe Speech::Grammar::Atom do
    Atom = Speech::Grammar::Atom

    it 'must have a word' do
	Atom.new('test').atom.must_equal 'test'
    end

    it 'must stringify a word' do
	Atom.new('test').to_s.must_equal 'test'
    end
end
