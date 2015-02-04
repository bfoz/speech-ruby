require 'set'

require_relative 'fsg/node'

module Speech
    # Finite State Grammar
    class FSG
	# @!attribute start
	#   @return [Node]  the {FSG}'s starting state
	attr_reader :start

	# @!attribute final
	#   @return [Node]  the {FSG}'s final state
	attr_reader :final

	# @param start	[Node]	the starting {Node}
	# @param final	[Node]	the ending {Node}
	def initialize(start, final)
	    @start = start
	    @final = final
	end

	# @return [Array] all of the nodes in the grammar
	def nodes(node=nil, set=nil)
	    if node
		if set.add?(node)
		    node.transitions.values.compact.each {|n| nodes(n, set) }
		end
		set
	    else
		nodes(start, Set.new).to_a
	    end
	end

	# @return [Hash]  A flattened table of transitions. The keys are 'from' and the values are transition tables of the form (word => to).
	def transitions(node=nil, hash={})
	    # Use the start node if no starting node was given
	    node ||= start

	    unless hash[node]     # Avoid recursive loops
		hash[node] = node.transitions
		node.transitions.each {|(k,n)| transitions(n,hash) }  # Recursion
	    end

	    hash
	end
    end
end
