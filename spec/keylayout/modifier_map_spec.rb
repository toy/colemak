require 'rspec'
require 'keylayout'

describe Keylayout::ModifierMap do
  subject{ described_class.new }

  describe '#index_for' do
    it 'returns the unique matching index' do
      indexes = Keylayout::Index.by_id
      i0 = indexes['0']
      i1 = indexes['1']
      i2 = indexes['2']
      i3 = indexes['3']
      i7 = indexes['7']

      subject.default_index = i7
      subject.add(i0, %w[caps anyShift?])
      subject.add(i0, %w[command])
      subject.add(i1, %w[anyOption command?])
      subject.add(i2, [])

      expect(subject.index_for(%w[caps])).to eq(i0)
      expect(subject.index_for(%w[caps shift])).to eq(i0)
      expect(subject.index_for(%w[caps rightShift])).to eq(i0)
      expect(subject.index_for(%w[command])).to eq(i0)

      expect(subject.index_for(%w[option])).to eq(i1)
      expect(subject.index_for(%w[rightOption])).to eq(i1)
      expect(subject.index_for(%w[option command])).to eq(i1)
      expect(subject.index_for(%w[rightOption command])).to eq(i1)

      expect(subject.index_for([])).to eq(i2)

      expect(subject.index_for(%w[shift option control])).to eq(i7)
    end

    it 'select the last onew when multiple indexes match' do
      indexes = Keylayout::Index.by_id
      i0 = indexes['0']
      i1 = indexes['1']

      subject.add(i0, %w[command? anyOption])
      subject.add(i1, %w[command anyOption?])

      expect(subject.index_for(%w[command option])).to eq(i1)
    end

    it 'falls back to the default index when there is no match' do
      indexes = Keylayout::Index.by_id
      i0 = indexes['0']
      i1 = indexes['1']
      i7 = indexes['7']

      subject.default_index = i7
      subject.add(i1, %w[command])

      expect(subject.index_for(%w[caps])).to eq(i7)
    end
  end
end
