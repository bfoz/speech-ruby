module Speech
    class MelFilterBank
	# @!attribute filters
	#   @return [Array<Float>]  the filter coefficients
	attr_accessor :filters

	# @!attribute length
	#   @return [Integer]  the size of the FFT output array to be filtered
	attr_accessor :length

	# @!attribute lower_frequency
	#   @return [Number]  the lower end of the filter bank, in Hertz
	attr_accessor :lower_frequency

	# @!attribute upper_frequency
	#   @return [Number]  the upper end of the filter bank, in Hertz
	attr_accessor :upper_frequency

	# @return [Number]  the frequency, in Hertz, converted to mels
	def self.hertz2mel(hertz)
	    1125.0 * Math.log(1 + hertz/700.0)
	end

	# @return [Number]  the frequency, in Mels, converted to Hertz
	def self.mel2hertz(mel)
	    700.0 * (Math.exp(mel/1125.0) - 1)
	end

	# @param filters    [Number]	the number of filters to create
	# @param length [Number]	the length of the FFT output array
	# @param lower  [Number]	the lower filter frequency (Hertz)
	# @param upper  [Number]	the upper filter frequency (Hertz)
	# @param sample_rate	[Number]    the sampling rate, in samples per second, of the data that was fed to the FFT
	def initialize(filters:, upper:, lower:, length:, sample_rate:)
	    raise "Sample rate must be at least twice the upper frequency" if upper > (sample_rate/2)

	    @length = length
	    @lower_frequency = lower
	    @upper_frequency = upper

	    fft_size = length
	    lower_mels = self.class.hertz2mel(@lower_frequency)
	    upper_mels = self.class.hertz2mel(@upper_frequency)
	    mel_spacing = (upper_mels - lower_mels)/(filters + 1)

	    # Generate equally spaced points in "Mel space"
	    hertz = (lower_mels..upper_mels).step(mel_spacing).map do |mel|
		# Convert it back to Hertz
		hz = self.class.mel2hertz(mel)

		# Round the frequency to the nearest FFT bin
		fft_bin = (hz*(fft_size+1)/sample_rate).to_i
		raise "FFT Bin (#{fft_bin}) out of range" if fft_bin > fft_size

		# Recover the frequency from the bin number, and return it
		fft_bin.to_f * sample_rate / (fft_size + 1)
	    end

	    raise "Rounding to FFT bins when FFT is too short causes divide by zero errors" if hertz.uniq.size != hertz.size

	    # Each filter is represented by 3 consecutive elements of hertz. Each
	    #  slice is the left, center, and right frequencies of the filter.
	    @filters = hertz.each_cons(3).map do |left, center, right|
		# For each filter, create an array of coefficients that's the same
		#  length as the FFT window
		Array.new(fft_size) do |i|
		    hz = i * sample_rate / (fft_size + 1)

		    if (hz > right) || (hz < left)
			0   # The filter's coefficients are 0 outside of its band
		    else
			left_line = (hz - left) / (center - left);
			right_line = (right - hz) / (right - center);
			[left_line, right_line].min
		    end
		end
	    end
	end

	# Filter the FFT spectrum using the Mel Filter Bank
	# @param spectrum   [Array] the output of the FFT that's to be filtered
	# @return
	def filter(spectrum)
	    filters.map do |coefficients|
		coefficients.zip(spectrum).map {|coefficient, power| coefficient * power }
					  .reduce(&:+)
	    end
	end
    end
end