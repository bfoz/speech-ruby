require 'minitest/autorun'
require 'speech/fft'

describe Speech::FFT do
    it 'must know the order of the butterfly' do
	Speech::FFT.new(160).fft_order.must_equal 7
    end

    it 'must detect a pure tone' do
	hertz = 440
	sps = 16000
	window_size = 512
	samples = Array.new(1024) {|i| t = i.to_f/sps; Math.sin(2*Math::PI*t*hertz)}

	fft = Speech::FFT.new(window_size)  # 10ms window
	bins = fft.process(samples)
	bins.size.must_equal window_size

	# There must be a spike in the bin for 440Hz
	index_440 = 440 * window_size / sps
	bins[index_440].must_be :>=, 30

	# Bins below 440Hz must be very small
	bins[0...index_440-1].all? {|b| b.abs < 1}.must_equal true

	# Bins above 440Hz must also be small
	# Note: There's a known inverse spike at bin 498 (~15KHz)
	bins[(index_440+2), 100].all? {|b| b.abs < 10}.must_equal true
    end

    it 'must handle silence' do
	window_size = 512
	samples = Array.new(1024, 0)

	fft = Speech::FFT.new(window_size)  # 10ms window

	bins = fft.process(samples)
	bins.size.must_equal window_size

	# Bins below 440Hz must be very small
	bins.all? {|b| b.abs < 1}.must_equal true
    end
end
