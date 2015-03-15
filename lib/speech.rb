require 'jsgf'

require_relative 'jsgf/grammar'
require_relative 'speech/fft'
require_relative 'speech/fsg'
require_relative 'speech/grammar'
require_relative 'speech/grammar/builder'
require_relative 'speech/mel_filter_bank'

module Speech
    def self.grammar(&block)
	Grammar::Builder.build(&block)
    end
end
