FROM ruby:2.6-alpine

ARG GEM_VERSION=0.5.0

RUN gem install nexaas-queue_time:$GEM_VERSION sidekiq redis-namespace
