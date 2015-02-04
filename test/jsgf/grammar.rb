require 'minitest/autorun'
require 'jsgf/parser'

require_relative '../../lib/jsgf/grammar'

describe JSGF::Grammar do
    let(:final) { FSG::Node.new }

    it 'must handle a single rule with a single atom' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar test; public <rule>=one;').parse

	start = FSG::Node.new('one' => final)
	grammar.to_fsg.must_equal FSG.new(start, final)
    end

    it 'must handle a single rule with a sequence of atoms' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar test; public <rule>=one two;').parse

	two = FSG::Node.new('two' => final)
	start = FSG::Node.new('one' => two)
	grammar.to_fsg.must_equal FSG.new(start, final)
    end

    it 'must handle a single rule with an alternation of atoms' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar test; public <rule>=one | two | three;').parse

	start = FSG::Node.new('one' => final, 'two' => final, 'three' => final)
	grammar.to_fsg.must_equal FSG.new(start, final)
    end

    it 'must handle a single rule with an optional atom' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar test; public <rule>=(one | two | three) [four];').parse

	four = FSG::Node.new('four' => final, null: final)
	start = FSG::Node.new('one' => four, 'two' => four, 'three' => four)
	grammar.to_fsg.must_equal FSG.new(start, final)
    end

    it 'must handle a single rule with an optional alternation' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar test; public <rule>=[one | two | three];').parse

	start = FSG::Node.new('one' => final, 'two' => final, 'three' => final, null: final)
	grammar.to_fsg.must_equal FSG.new(start, final)
    end

    it 'must handle multiple public rules' do
	grammar = JSGF::Parser.new('#JSGF V1.0; grammar test; public <rule1>=one | two | three; public <rule2>=four | five | six;').parse

	start = FSG::Node.new('one' => final, 'two' => final, 'three' => final, 'four' => final, 'five' => final, 'six' => final)
	grammar.to_fsg.must_equal FSG.new(start, final)
    end
end
