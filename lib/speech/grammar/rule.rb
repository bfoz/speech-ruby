require_relative 'atom'

module Speech
    class Grammar
	class Rule < Array
	    attr_accessor :block

	    # Convert a string containing a single atom into an {Atom} or a rule reference
	    # @param atom	[String]	the text to parse
	    def self.parse_atom(atom)
		case atom
		    when /\<(.*)\>/, /:(.*)/ then {name:$1}
		    else
			Atom.new(atom)
		end
	    end
	end
    end
end
