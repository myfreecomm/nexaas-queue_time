# frozen_string_literal: true

require 'spec_helper'
require 'nexaas/queue_time/dogstatsd'

RSpec.describe Nexaas::QueueTime::DogStatsd do
  describe '.timing' do
    let(:metric) { 42 }
    subject { described_class.timing('some-metric', metric, sample_rate: 1) }

    it 'opens a socket' do
      expect(Datadog::Statsd).to receive(:open).with(
        nil,
        nil,
        socket_path: '/var/run/datadog/dsd.socket'
      )
      subject
    end

    it 'sends a timing metric to DogStatsd server' do
      expect_any_instance_of(Datadog::Statsd).to receive(:timing).with(
        'some-metric', metric, sample_rate: 1
      )
      subject
    end
  end
end
