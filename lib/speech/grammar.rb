module Speech
    class Grammar
	# @!attribute rules
	#   @return [Array<Rule>]  the rules of the {Grammar}
	attr_reader :rules

	# @param rules [Hash]	the rules to use for the {Grammar}
	def initialize(rules)
	    @rules = rules
	end
    end
end
