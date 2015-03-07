require 'minitest/autorun'
require 'speech/grammar/builder'

describe Speech::Grammar::Builder do
    Builder = Speech::Grammar::Builder

    it 'must build a single-atom rule' do
	grammar = Builder.new.build do
	    rule rule1: 'one'
	end

	grammar.rules.size.must_equal 1
	grammar.rules['rule1'].must_equal [Atom.new('one')]
    end

    it 'must build a multi-atom rule' do
	grammar = Builder.build {rule rule1: 'one two' }
	grammar.rules.size.must_equal 1
	grammar.rules['rule1'].must_equal [Atom.new('one'), Atom.new('two')]
    end

    it 'must build a rule with a rule reference as a Symbol' do
	grammar = Builder.build do
	    rule rule1: :one
	    rule one: 'one'
	end

	grammar.rules.size.must_equal 2
	grammar.rules['rule1'].must_equal [{name:'one'}]
    end

    it 'must build a rule with a JSGF-style rule reference embedded in a string' do
	grammar = Builder.build do
	    rule rule1: '<one>'
	    rule one: 'one'
	end

	grammar.rules.size.must_equal 2
	grammar.rules['rule1'].must_equal [{name:'one'}]
    end

    it 'must build a rule with a rule reference symbol embedded in a string' do
	grammar = Builder.build do
	    rule rule1: ':one'
	    rule one: 'one'
	end

	grammar.rules.size.must_equal 2
	grammar.rules['rule1'].must_equal [{name:'one'}]
    end

    describe 'alternation' do
	it 'must build an alternation from an array of atoms' do
	    grammar = Builder.build do
		rule rule1: %w{one two}
	    end
	    grammar.rules.size.must_equal 1
	    grammar.rules['rule1'].first.must_be_kind_of Alternation
	    grammar.rules['rule1'].first.elements.must_equal [Atom.new('one'), Atom.new('two')]
	end

	it 'must build an alternation from an array of rule reference symbols' do
	    grammar = Builder.build do
		rule rule1: [:one, :two]
		rule one: 'one'
		rule two: 'two'
	    end

	    grammar.rules.size.must_equal 3
	    grammar.rules['rule1'].first.must_be_kind_of Alternation
	    grammar.rules['rule1'].first.elements.must_equal [{name:'one'}, {name:'two'}]
	end

	it 'must build an alternation from an array of strings containing embedded rule reference symbols' do
	    grammar = Builder.build do
		rule rule1: %w[:one :two]
		rule one: 'one'
		rule two: 'two'
	    end

	    grammar.rules.size.must_equal 3
	    grammar.rules['rule1'].first.must_be_kind_of Alternation
	    grammar.rules['rule1'].first.elements.must_equal [{name:'one'}, {name:'two'}]
	end

	it 'must build an alternation from an array of strings containing embedded JSGF-style rule reference names' do
	    grammar = Builder.build do
		rule rule1: %w[<one> <two>]
		rule one: 'one'
		rule two: 'two'
	    end

	    grammar.rules.size.must_equal 3
	    grammar.rules['rule1'].first.must_be_kind_of Alternation
	    grammar.rules['rule1'].first.elements.must_equal [{name:'one'}, {name:'two'}]
	end
    end
end