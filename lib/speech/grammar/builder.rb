require 'jsgf'

require_relative 'alternation'
require_relative 'rule'

module Speech
    class Grammar
	class Builder
	    def initialize
		@rules = {}
	    end

	    # Convenience method for instantiating a builder and then building a {Grammar}
	    # @return [Grammar] a new {Grammar} built from the block argument
	    def self.build(&block)
		new.build(&block)
	    end

	    # @return [Grammar] a new {Grammar} built from the block argument
	    def build(&block)
		instance_eval(&block) if block_given?
		Grammar.new(@rules)
	    end

	    # Create a new rule using the provided name and string
	    #   By default, all new rules are private, unless they're root rules
	    # @example
	    #   rule rule1: 'This is a rule'
	    #   rule rule2: ['one', 'two']
	    #   rule rule3: 'This is not :rule2'
	    def rule(**options)
		options.each do |name, v|
		    @rules[name.to_s] = case v
			when Array	then Rule.new [Alternation.new(*v)]
			when Symbol	then Rule.new [{name:v.to_s}]
			else
			    v.split(' ').map {|a| Rule.parse_atom(a) }
		    end
		end
	    end
	end
    end
end
