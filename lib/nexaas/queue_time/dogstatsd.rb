# frozen_string_literal: true

require 'datadog/statsd'

module Nexaas
  module QueueTime
    class DogStatsd
      # By default, Datadog::Statsd opens a UDP connection with a given host and port.
      # Instead, we are giving it a socket path so it communicates with the statsd server via UDS.
      #
      # This approach is easier to setup in containerized environments since all it requires
      # is the path to the socket file instead of the host address.
      #
      # UDS also performs better than UDP,
      # although the app would need to receive huge traffic to actually feel the difference.
      def self.timing(metric_name, metric, options = {})
        Datadog::Statsd.open(nil, nil, socket_path: '/var/run/datadog/dsd.socket') do |statsd|
          statsd.timing(metric_name, metric, options)
        end
      end
    end
  end
end
