require 'rspec'

module ThomasUtils
  describe KeyComparer do
    describe '#to_s' do
      %w(= > >= <= < !=).each do |comparer|
        context "when #{comparer}" do
          subject { "#{KeyComparer.new(key, comparer)}" }
          let(:key) { :key }
          it { is_expected.to eq("key #{comparer}") }

          context 'with a different key' do
            let(:key) { :different_key }
            it { is_expected.to eq("different_key #{comparer}") }
          end
        end
      end

      context 'when the key is an array' do
        let(:key) { %w(a b c d) }
        subject { "#{KeyComparer.new(key, '>')}" }
        it { is_expected.to eq('(a,b,c,d) >') }

        context 'with a different key' do
          let(:key) { %w(e f g h) }
          it { is_expected.to eq('(e,f,g,h) >') }
        end
      end
    end

    describe '#key' do
      let(:key) { :key }

      subject { KeyComparer.new(key, '>') }

      its(:key) { is_expected.to eq(key) }

      context 'with a different key' do
        let(:key) { :different_key }
        its(:key) { is_expected.to eq(key) }
      end

      context 'with an array key' do
        let(:key) { %w(array of keys) }
        its(:key) { is_expected.to eq(key) }
      end
    end

    describe '#new_key' do
      let(:new_key) { :updated_key }
      subject { "#{KeyComparer.new(:key, '>').new_key(new_key)}" }

      it 'should return an updated KeyComparer with the new key' do
        is_expected.to eq('updated_key >')
      end


      context 'with a different key' do
        let(:new_key) { :different_key }

        it 'should return an updated KeyComparer with the new key' do
          is_expected.to eq('different_key >')
        end
      end
    end

    describe '#quote' do
      let(:key) { Faker::Lorem.word }
      let(:comparer) { :> }
      let(:quote) { '`' }
      let(:quoted_key) { "`#{key}` >" }

      subject { KeyComparer.new(key, comparer).quote(quote) }

      it { is_expected.to eq(quoted_key) }

      context 'with a different quote type' do
        let(:quote) { '"' }
        let(:quoted_key) { %Q{"#{key}" >} }

        it { is_expected.to eq(quoted_key) }
      end

      context 'with a different comparer' do
        let(:comparer) { :<= }
        let(:quoted_key) { "`#{key}` <=" }

        it { is_expected.to eq(quoted_key) }
      end

      context 'when the key itself is a KeyChild' do
        let(:key) { KeyChild.new(Faker::Lorem.word, Faker::Lorem.word) }
        let(:quoted_key) { "`#{key.key}`.`#{key.child}` >" }

        it { is_expected.to eq(quoted_key) }
      end
    end

    shared_examples_for 'a comparison operator' do |method|
      describe "##{method}" do
        let(:lhs) { KeyComparer.new('key', '>') }
        let(:rhs) { KeyComparer.new('key', '>') }
        subject { lhs.public_send(method, rhs) }

        it { is_expected.to eq(true) }

        context 'with different keys' do
          let(:rhs) { KeyComparer.new('other key', '>') }
          it { is_expected.to eq(false) }
        end

        context 'with different comprarers' do
          let(:rhs) { KeyComparer.new('key', '<') }
          it { is_expected.to eq(false) }
        end
      end
    end

    it_behaves_like 'a comparison operator', :==
    it_behaves_like 'a comparison operator', :eql?

    describe '#hash' do
      let(:comparer_string) { subject.to_s }
      subject { KeyComparer.new('key', '>') }

      its(:hash) { is_expected.to eq(comparer_string.hash) }

      context 'with a different KeyComparer' do
        subject { KeyComparer.new('other_key', '<=') }

        its(:hash) { is_expected.to eq(comparer_string.hash) }
      end
    end

  end
end

describe Symbol do
  {eq: '=', gt: '>', ge: '>=', le: '<=', lt: '<', ne: '!='}.each do |operator, comparer|
    let(:key) { :key }
    describe "##{operator}" do
      subject { "#{key.public_send(operator)}" }
      it { is_expected.to eq("key #{comparer}") }
    end
  end
end

describe Array do
  {eq: '=', gt: '>', ge: '>=', le: '<=', lt: '<', ne: '!='}.each do |operator, comparer|
    let(:key) { %w(lots of keys) }
    describe "##{operator}" do
      subject { "#{key.public_send(operator)}" }
      it { is_expected.to eq("(lots,of,keys) #{comparer}") }
    end
  end
end
