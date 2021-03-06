require 'rspec'

module ThomasUtils
  describe Observer do

    let(:klass) do
      Struct.new(:observation) { include Observer }
    end
    let(:observation) { double(:observation) }
    let(:observer) { klass.new(observation) }

    shared_examples_for 'a method delegating to an Observation' do |method|
      let(:args) { Faker::Lorem.words }

      it 'calls the method on the observation' do
        expect(observation).to receive(method).with(*args)
        observer.public_send(method, *args)
      end
    end

    it_behaves_like 'a method delegating to an Observation', :on_success
    it_behaves_like 'a method delegating to an Observation', :on_failure
    it_behaves_like 'a method delegating to an Observation', :on_complete
    it_behaves_like 'a method delegating to an Observation', :on_timed
    it_behaves_like 'a method delegating to an Observation', :join
    it_behaves_like 'a method delegating to an Observation', :get
    it_behaves_like 'a method delegating to an Observation', :resolved_at
    it_behaves_like 'a method delegating to an Observation', :then
    it_behaves_like 'a method delegating to an Observation', :none_fallback
    it_behaves_like 'a method delegating to an Observation', :fallback
    it_behaves_like 'a method delegating to an Observation', :ensure
    it_behaves_like 'a method delegating to an Observation', :on_success_ensure
    it_behaves_like 'a method delegating to an Observation', :on_failure_ensure

  end
end
