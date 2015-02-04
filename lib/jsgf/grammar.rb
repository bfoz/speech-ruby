require_relative '../speech/fsg'

module JSGF
    class Grammar
	def to_fsg
	    raise StandardError, "The grammar must have at least one root" unless roots
	    raise StandardError, "The grammar must contain at least one public rule" if roots.empty?

	    final = Speech::FSG::Node.new
	    transitions = roots.map {|(name, rule)| expand_atom(rule, final) }.reduce {|a,b| merge_transitions(a, b) }
	    start = Speech::FSG::Node.new(transitions)
	    Speech::FSG.new(start, final)
	end

	private

	# Recursively merge the two transition sets, creating new nodes for any duplicates
	# @param left   [Hash]
	# @param right  [Hash]
	# @return [Hash] a new set of transitions
	def merge_transitions(left, right)
	    left.merge(right) do |word, lhs, rhs|
		if (lhs === rhs)
		    lhs
		else
		    Speech::FSG::Node.new(merge_transitions(lhs.transitions, rhs.transitions))
		end
	    end
	end

	def expand_atom(atom, end_state)
	    case atom
		when JSGF::Alternation
		    atom.map {|a| expand_atom(a, end_state) }
			.reduce {|a,b| merge_transitions(a, b) }
			.tap {|transitions| transitions[:null] = end_state if atom.optional }
		when JSGF::Optional
		    expand_atom(atom.elements, end_state).tap {|transitions| transitions[:null] = end_state }
		when Array
		    # Start with the last atom in the sequence and build a set of state transitions from the end
		    start_state = atom.reverse.reduce(end_state) do |memo, a|
			transitions = expand_atom(a, memo)
			Speech::FSG::Node.new(transitions)
		    end
		    start_state.transitions
		when Hash
		    if atom[:atom]  # A bare word
			{atom[:atom] => end_state}  # Transition on the bare word
		    elsif atom[:name]   # A reference to another rule (potentially recursive)
			expand_atom(rules[atom[:name]], end_state)
		    end
	    end
	end
    end
end
