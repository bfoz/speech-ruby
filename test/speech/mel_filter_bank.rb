require 'minitest/autorun'
require 'speech/mel_filter_bank'

describe Speech::MelFilterBank do
    let(:mel) { Speech::MelFilterBank.new(filters:20, length:100, sample_rate:1000, upper:500, lower:100) }

    it 'must create the correct number of filters' do
	mel.filters.size.must_equal 20
    end

    it 'must create filters of the correct length' do
	mel.filters.all? {|f| f.length == mel.length}.must_equal true
    end

    it 'must filter a simple FFT' do
	spectrum = Array.new(mel.length) {|i| (i == 20) ? 1 : 0 }
	mel_spectrum = mel.filter(spectrum)
	mel_spectrum.size.must_equal mel.filters.size
	mel_spectrum[0..3].all?(&:zero?).must_equal true
	mel_spectrum[4].must_be :>, 0
	mel_spectrum[5].must_be :>, 0
	mel_spectrum[6..-1].all?(&:zero?).must_equal true
    end
end
