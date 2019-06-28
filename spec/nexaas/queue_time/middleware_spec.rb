# frozen_string_literal: true

require 'spec_helper'
require 'nexaas/queue_time/middleware'

RSpec.describe Nexaas::QueueTime::Middleware do
  let(:app) { ->(env) { [200, env, ['OK']] } }

  subject { described_class.new(app) }

  describe '#call' do
    let(:queue_time) { 0.5 }
    let(:request_start) { Time.now.to_f - queue_time }
    let(:request_env) do
      { 'PATH_INFO' => '/index', 'HTTP_X_REQUEST_START' => request_start }
    end

    it 'does not alter request' do
      http_code, env, body = subject.call(request_env)

      expect(http_code).to eq(200)
      expect(env).to eq(request_env)
      expect(body).to eq(['OK'])
    end

    it 'sends metric to statsd' do
      queue_time_in_ms = queue_time * 1000
      expect_any_instance_of(Datadog::Statsd).to receive(:timing).with(
        described_class::METRIC_NAME,
        be_within(0.3).of(queue_time_in_ms),
        sample_rate: 1
      )
      subject.call(request_env)
    end
  end
end
