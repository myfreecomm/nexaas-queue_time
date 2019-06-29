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
      {
        'PATH_INFO' => '/index',
        'HTTP_X_REQUEST_START' => "t=#{request_start}"
      }
    end

    it 'does not alter request' do
      http_code, env, body = subject.call(request_env)

      expect(http_code).to eq(200)
      expect(env).to eq(request_env)
      expect(body).to eq(['OK'])
    end

    it 'opens socket connection' do
      expect(Datadog::Statsd).to receive(:open).with(
        nil,
        nil,
        socket_path: '/var/run/datadog/dsd.socket'
      )
      subject.call(request_env)
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

    context 'when timestamp in HTTP_X_REQUEST_START is given as an integer' do
      let(:queue_time) { 1 }
      let(:request_start) { Time.now.to_i - queue_time }

      it 'sends metric to statsd' do
        queue_time_in_ms = queue_time * 1000
        expect_any_instance_of(Datadog::Statsd).to receive(:timing).with(
          described_class::METRIC_NAME,
          be_within(2000).of(queue_time_in_ms),
          sample_rate: 1
        )
        subject.call(request_env)
      end
    end

    context 'when HTTP_X_REQUEST_START is given as string' do
      let(:request_start) { (Time.now.to_f - queue_time).to_s }

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

    context 'when HTTP_X_REQUEST_START is given in an unexpected format' do
      before :each do
        request_env['HTTP_X_REQUEST_START'] = 'something else'
      end

      it 'does not alter request' do
        http_code, env, body = subject.call(request_env)

        expect(http_code).to eq(200)
        expect(env).to eq(request_env)
        expect(body).to eq(['OK'])
      end

      it 'does not send metric to statsd' do
        expect_any_instance_of(Datadog::Statsd).not_to receive(:timing)

        subject.call(request_env)
      end
    end

    context 'when HTTP_X_REQUEST_START is not given' do
      before :each do
        request_env.delete('HTTP_X_REQUEST_START')
      end

      it 'does not alter request' do
        http_code, env, body = subject.call(request_env)

        expect(http_code).to eq(200)
        expect(env).to eq(request_env)
        expect(body).to eq(['OK'])
      end

      it 'does not send metric to statsd' do
        expect_any_instance_of(Datadog::Statsd).not_to receive(:timing)

        subject.call(request_env)
      end
    end
  end
end
