module Speech
    class FFT
	attr_reader :fft_order
	attr_reader :window

	# @!attribute size
	#   @return [Integer]	the number of input samples to transform
	attr_reader :size

	# @param window_size	[Integer]   the number of samples that will be passed in each call to #process
	def initialize(window_size)
	    @size = window_size

	    # Use the Hamming window from http://en.wikipedia.org/wiki/Window_function#Hamming_window
	    @window = Array.new(window_size) {|i| 25.0/46 - 21.0/46 * Math.cos(2 * i * Math::PI / (window_size - 1)) }

	    # Precompute the twiddle factors
	    twiddle = (0...window_size/4).map {|i| 2 * Math::PI * i / window_size }
	    @twiddle_cos = twiddle.map {|i| Math.cos(i) }
	    @twiddle_sin = twiddle.map {|i| Math.sin(i) }

	    # Derive the FFT order from the size
	    @fft_order = 0
	    j = size
	    while j > 1
		j >>= 1
		@fft_order += 1
	    end
	end

	# @param samples [Array<Float>] new samples to process
	def process(samples)
	    # Check that there are enough samples
	    if samples.size > size
		# Apply the window function
		windowed_samples = window.zip(samples).map {|a,b| a*b}

		# Transform the windowed samples
		fft(windowed_samples)
	    else
		[]
	    end
	end

    private

	# Basic butterfly with real twiddle factors:
	# x[i]          = x[i] +  1 * x[i + (1<<k)]
	# x[i + (1<<k)] = x[i] + -1 * x[i + (1<<k)]
	def basic_butterfly(samples, i, k)
	    a = samples[i];
	    samples[i] = (a + samples[i + (1 << k)]);
	    samples[i + (1 << k)] = (a - samples[i + (1 << k)]);
	end

	# This is the implementation from "Real-Valued Fast Fourier Transform
	#  Algorithms" by Henrik V. Sorensen et al., IEEE Transactions on
	#  Acoustics, Speech, and Signal Processing, vol. 35, no.6, as
	#  implemented by Sphinx, and translated into Ruby.
	# @param samples    [Array] the samples to transform
	# @return [Array]   the resulting bins
	def fft(samples)
	    x = samples
	    m = fft_order
	    n = size

	    # Bit-reverse the input
	    j = 0;
	    (n-1).times do |i|
		if i < j
		    x[i], x[j] = x[j], x[i]
		end

		# NOTE!! This only works for fft_size == 512
		k = n/2
		while k <= j
		    raise if j == 0 && k == 0
		    j -= k
		    k /= 2
		end
		j += k
	    end

	    # Basic butterflies (2-point FFT, real twiddle factors):
	    # x[i]   = x[i] +  1 * x[i+1]
	    # x[i+1] = x[i] + -1 * x[i+1]
	    (0...n).step(2).each {|i| basic_butterfly(x, i, 0) }

	    # The rest of the butterflies, in stages from 1..m
	    (1...m).each do |k|
		n4 = k - 1
		n2 = k
		n1 = k + 1

		# Stride over each (1 << (k+1)) points
		(0...n).step(1 << n1) do |i|
		    # Basic butterfly with real twiddle factors:
		    # x[i]          = x[i] +  1 * x[i + (1<<k)]
		    # x[i + (1<<k)] = x[i] + -1 * x[i + (1<<k)]
		    basic_butterfly(x, i, n2)

		    # The other ones with real twiddle factors:
		    # x[i + (1<<k) + (1<<(k-1))] = 0 * x[i + (1<<k-1)] + -1 * x[i + (1<<k) + (1<<k-1)]
		    # x[i + (1<<(k-1))] = 1 * x[i + (1<<k-1)] +  0 * x[i + (1<<k) + (1<<k-1)]
		    x[i + (1 << n2) + (1 << n4)] = -x[i + (1 << n2) + (1 << n4)]
		    x[i + (1 << n4)] = x[i + (1 << n4)]

		    # Butterflies with complex twiddle factors.
		    # There are (1<<k-1) of them.
		    (1...(1<<n4)).each do |j|
			i1 = i + j;
			i2 = i + (1 << n2) - j
			i3 = i + (1 << n2) + j
			i4 = i + (1 << n2) + (1 << n2) - j

			cc = @twiddle_cos[j << (m - n1)]    # real(W[j * n / (1<<(k+1))])
			ss = @twiddle_sin[j << (m - n1)]    # imag(W[j * n / (1<<(k+1))])

			# There are some symmetry properties which allow us
			# to get away with only four multiplications here
			t1 = (x[i3] * cc) + (x[i4] * ss)
			t2 = (x[i3] * ss) - (x[i4] * cc)

			x[i4] = (x[i2] - t2)
			x[i3] = (-x[i2] - t2)
			x[i2] = (x[i1] - t1)
			x[i1] = (x[i1] + t1)
		    end
		end
	    end

	    samples[0, size]
	end
    end
end
