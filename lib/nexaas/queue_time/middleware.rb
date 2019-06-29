# frozen_string_literal: true

require 'datadog/statsd'

module Nexaas
  module QueueTime
    # This middleware calculates the time a request has been waiting
    #   in the queue before being served by the application server.
    #
    # It requires the header `X_REQUEST_START`. This header contains
    #   the timestamp of when the request first apperead in the stack.
    # This header is usually set by a LoadBalancer, Reverse Proxy or Router.
    #
    # The format of the header **must** match:
    #   `t=TIMESTAMP`, where TIMESTAMP is the unix timestamp.
    # This format is supported by APMs such as New Relic and Scout
    class Middleware
      METRIC_NAME = 'request.queue_time'
      HEADER_FORMAT_PATTERN = /
        ^   # Beginning of line
        t=  #
        \d+ # At least 1 digit
        \.? # Optionally a dot may be used for fractional timestamps
        \d* # Optionally more digits after the dot
        $   # End of line
      /x

      def initialize(app)
        @app = app
      end

      def call(env)
        request_start_header = env['HTTP_X_REQUEST_START']
        if request_start_header&.match?(HEADER_FORMAT_PATTERN)
          left_queue_at = Time.now.to_f
          metric = calculate_queue_time_in_ms(left_queue_at, request_start_header)
          send_metric(metric)
        end

        @app.call(env)
      end

      private

      def calculate_queue_time_in_ms(left_queue_at, request_start_header)
        entered_queue_at = extract_timestamp(request_start_header)
        (left_queue_at - entered_queue_at.to_f) * 1000
      end

      def extract_timestamp(entered_queue)
        entered_queue.delete('t=')
      end

      # By default, Datadog::Statsd opens a UDP connection with a given host and port.
      # Instead, we are giving it a socket path so it communicates with the statsd server via UDS.
      #
      # This approach is easier to setup in containerized environments since all it requires
      # is the path to the socket file instead of the host address.
      #
      # UDS also performs better than UDP,
      # although the app would need to receive huge traffic to actually feel the difference.
      def send_metric(metric)
        Datadog::Statsd.open(nil, nil, socket_path: '/var/run/datadog/dsd.socket') do |statsd|
          statsd.timing(METRIC_NAME, metric.to_i, sample_rate: 1)
        end
      end
    end
  end
end
