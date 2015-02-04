module Speech
    class FSG
	# A Node in a Finite State Grammar
	class Node
	    attr_accessor :transitions

	    # @example
	    #   Node.new('a' => next_state)
	    def initialize(options={})
		@transitions = options
	    end

	    def ==(other)
		transitions == other.transitions
	    end

	    # @param key    [String]	the transition word to look up
	    # @return [Node]	the destination {Node} for the given key, or nil if the key wasn't found
	    def [](key)
		transitions[key]
	    end

	    # @param key    [String]	the transition word to set the destination of
	    # @param node   [Node]	the destination {Node} for the given transition word
	    def []=(key, node)
		transitions[key] = node
	    end
	end
    end
end