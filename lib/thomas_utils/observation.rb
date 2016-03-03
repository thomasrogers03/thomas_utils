module ThomasUtils
  class Observation
    extend Forwardable

    def_delegator :@observable, :value!, :get

    def initialize(executor, observable)
      @executor = executor
      @observable = observable
    end

    def on_success
      @observable.add_observer do |_, value, error|
        @executor.post do
          yield value unless error
        end
      end
      self
    end

    def on_failure
      @observable.add_observer do |_, _, error|
        @executor.post do
          yield error if error
        end
      end
      self
    end

    def on_complete
      @observable.add_observer do |_, value, error|
        @executor.post do
          yield value, error
        end
      end
      self
    end

    def join
      @observable.value
      self
    end

    def then
      observable = Concurrent::IVar.new
      on_complete do |value, error|
        if error
          observable.fail(error)
        else
          result = yield value
          observable.set(result)
        end
      end
      Observation.new(@executor, observable)
    end

  end
end