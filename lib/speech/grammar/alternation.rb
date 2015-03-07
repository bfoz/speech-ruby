require_relative 'rule'

module Speech
    class Grammar
	class Alternation
	    include Enumerable

	    attr_reader :elements
	    attr_accessor :optional
	    attr_reader :tags

	    def initialize(*args)
		@elements = args.map do |a|
		    case a
			when String then Rule.parse_atom(a)
			when Symbol then {name:a.to_s}
			else
			    a
		    end
		end

		@optional = false
		@tags = []
	    end

	    # @group Enumerable
	    def each(*args, &block)
		elements.each(*args, &block)
	    end
	    # @endgroup

	    def push(*args)
		@elements.push *args
	    end

	    # @group Attributes
	    def size
		@elements.size
	    end
	    # @endgroup
	end
    end
end
