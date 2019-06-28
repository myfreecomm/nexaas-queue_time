# frozen_string_literal: true

require 'datadog/statsd'

module Nexaas
  module QueueTime
    class Middleware
      METRIC_NAME = 'request.queue_time'

      def initialize(app)
        @app = app end

      def call(env)
        left_queue = Time.now.to_f
        metric = queue_time_in_ms(left_queue, env)
        send_metric(metric)

        @app.call(env)
      end

      private

      def queue_time_in_ms(left_queue, env)
        entered_queue = env['HTTP_X_REQUEST_START']
        return nil if entered_queue.nil?

        (left_queue - entered_queue.to_f) * 1000
      end

      def send_metric(metric)
        return unless metric

        Datadog::Statsd.open(nil, nil, socket_path: '/var/run/datadog/dsd.socket') do |statsd|
          statsd.timing(METRIC_NAME, metric.to_i, sample_rate: 1)
        end
      end
    end
  end
end
