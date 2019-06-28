# frozen_string_literal: true

require 'datadog/statsd'

module Nexaas
  module QueueTime
    class Middleware
      METRIC_NAME = 'request.queue_time'

      def initialize(app)
        @app = app
      end

      def call(env)
        left_queue = Time.now.to_f
        metric = queue_time_in_ms(left_queue, env)
        send_metric(metric)

        @app.call(env)
      end

      private

      def queue_time_in_ms(left_queue, env)
        entered_queue = env['HTTP_X_REQUEST_START']
        (left_queue - entered_queue) * 1000
      end

      def send_metric(metric)
        Datadog::Statsd.open('localhost', 8125) do |statsd|
          statsd.timing(METRIC_NAME, metric, sample_rate: 1)
        end
      end
    end
  end
end
