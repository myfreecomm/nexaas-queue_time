# frozen_string_literal: true

require 'spec_helper'
require 'nexaas/queue_time/sidekiq'

RSpec.describe Nexaas::QueueTime::Sidekiq do
  describe '.measure_latency' do
    it 'sends latency for all queues to DogStatsd' do
      queues = [
        double(:queue1, name: 'queue-1', latency: 5.32),
        double(:queue2, name: 'queue-2', latency: 12.8714)
      ]
      allow(Sidekiq::Queue).to receive(:all).and_return(queues)
      expect(Nexaas::QueueTime::DogStatsd).to receive(:timing)
        .with(
          described_class::METRIC_NAME,
          5320,
          sample_rate: 1,
          tags: { queue_name: 'queue-1' }
        ).once
      expect(Nexaas::QueueTime::DogStatsd).to receive(:timing)
        .with(
          described_class::METRIC_NAME,
          12_872,
          sample_rate: 1,
          tags: { queue_name: 'queue-2' }
        ).once
      described_class.measure_latency
    end
  end
end
