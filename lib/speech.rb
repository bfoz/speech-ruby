require 'jsgf'

require_relative 'jsgf/grammar'
require_relative 'speech/fsg'
require_relative 'speech/grammar'
require_relative 'speech/grammar/builder'

module Speech
    def self.grammar(&block)
	Grammar::Builder.build(&block)
    end
end
