require 'minitest/autorun'
require 'speech/fsg'

describe Speech::FSG do
    FSG = Speech::FSG

    it 'must have nodes' do
	final = FSG::Node.new
	start = FSG::Node.new('a' => final, 'b' => final)

	fsg = FSG.new(start, final)
	fsg.nodes.must_equal [start, final]
    end

    it 'must have transitions' do
	final = FSG::Node.new
	start = FSG::Node.new('a' => final, 'b' => final)

	fsg = FSG.new(start, final)
	fsg.transitions.must_equal Hash[start => {'a' => final, 'b' => final}, final => {}]
    end
end
