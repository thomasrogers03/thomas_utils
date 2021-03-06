require 'rspec'

module ThomasUtils
  describe PerformanceMonitor do

    let(:logger) { InMemoryLogger.new }
    let(:monitor) { PerformanceMonitor.new(logger) }

    describe '#monitor' do
      let(:sender) { double(:sender) }
      let(:method) { Faker::Lorem.word.to_sym }
      let(:monitor_name) { Faker::Lorem.sentence }
      let(:initialized_at) { Time.now }
      let(:duration) { (rand * 60).round(4) }
      let(:resolved_at) { initialized_at + duration }
      let(:result) { Faker::Lorem.sentence }
      let(:const_var) { ConstantVar.new(resolved_at, result, error) }
      let(:future) { Observation.new(Future::IMMEDIATE_EXECUTOR, const_var, initialized_at) }
      let(:error) { nil }
      let(:log_item) do
        {
            sender: sender,
            method: method,
            name: monitor_name,
            started_at: initialized_at,
            completed_at: resolved_at,
            duration: duration,
            error: error,
            result: result
        }
      end

      subject { logger.log }

      context 'with an observation' do
        before do
          monitor.monitor(sender, method, monitor_name, future)
          future.join
        end

        it { is_expected.to include(log_item) }

        context 'with an error' do
          let(:error) { StandardError.new(Faker::Lorem.sentence) }

          it { is_expected.to include(log_item) }
        end

        context 'when the monitor name is a hash' do
          let(:monitor_name) { Faker::Lorem.words.inject({}) { |memo, word| memo.merge!(word => Faker::Lorem.sentence) } }
          let(:log_item) do
            {
                sender: sender,
                method: method,
                started_at: initialized_at,
                completed_at: resolved_at,
                duration: duration,
                error: error,
                result: result,
            }.merge(monitor_name)
          end

          it { is_expected.to include(log_item) }
        end
      end

      context 'with a block' do
        before do
          allow(Time).to receive(:now).and_return(initialized_at, resolved_at)
          monitor.monitor(sender, method, monitor_name) { result }
          future.get
        end

        it { is_expected.to include(log_item) }
      end
    end
  end
end
