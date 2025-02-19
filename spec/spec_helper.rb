require 'sidekiq/limit_fetch'

Sidekiq.logger = nil
Sidekiq.redis = { namespace: ENV['namespace'] }

RSpec.configure do |config|
  config.order = :random
  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.before do
    Sidekiq::Queue.reset_instances!
    Sidekiq.redis do |it|
      clean_redis = ->(queue) do
        it.pipelined do |p|
          p.del "limit_fetch:limit:#{queue}"
          p.del "limit_fetch:process_limit:#{queue}"
          p.del "limit_fetch:busy:#{queue}"
          p.del "limit_fetch:probed:#{queue}"
          p.del "limit_fetch:pause:#{queue}"
          p.del "limit_fetch:block:#{queue}"
        end
      end

      clean_redis.call(name) if defined?(name)
      queues.each(&clean_redis) if defined?(queues) and queues.is_a? Array
    end
  end
end
