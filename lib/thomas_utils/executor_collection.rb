module ThomasUtils
  class ExecutorCollection
    extend Forwardable

    def_delegator :@collection, :[]

    def initialize
      @collection = Concurrent::Map.new
    end

    def build(name, max_threads, max_queue)
      @collection[name] = Concurrent::ThreadPoolExecutor.new(
          min_threads: 0,
          max_threads: max_threads,
          max_queue: max_queue,
          fallback_policy: :caller_runs,
          auto_terminate: true
      )
    end

  end
end
