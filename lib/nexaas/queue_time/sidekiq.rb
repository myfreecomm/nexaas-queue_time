# frozen_string_literal: true

require 'nexaas/queue_time/dogstatsd'
require 'sidekiq/api'

module Nexaas
  module QueueTime
    # Measures the latency for all Sidekiq queues
    # and send it to Datadog.
    class Sidekiq
      METRIC_NAME = 'sidekiq.queue.latency_ms'

      if ENV['REDIS_NAMESPACE']
        ::Sidekiq.configure_client do |config|
          config.redis = { namespace: ENV['REDIS_NAMESPACE'] }
        end
      end

      def self.measure_latency
        ::Sidekiq::Queue.all.each do |queue|
          latency_in_ms = (queue.latency * 1000).ceil
          opts = {
            sample_rate: 1,
            tags: { queue_name: queue.name }
          }
          DogStatsd.timing(METRIC_NAME, latency_in_ms, opts)
        end
      end
    end
  end
end
