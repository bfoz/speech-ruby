module Speech
    class Grammar
	class Atom
	    # @!attribute atom
	    #   @return [String]  the atom of the {Atom}
	    attr_accessor :atom

	    # @param atom	[String]    the atom of the {Atom}
	    def initialize(atom)
		@atom = atom
	    end

	    def eql?(other)
		@atom.eql?(other.atom)
	    end
	    alias == eql?

	    # Stringify in a manner suitable for output to a JSGF file
	    def to_s
		atom ? atom.to_s : nil
	    end
	end
    end
end
