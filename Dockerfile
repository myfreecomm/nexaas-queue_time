FROM ruby:2.6-alpine

ARG GEM_VERSION=0.4.0-rc2

RUN gem install nexaas-queue_time:$GEM_VERSION
RUN gem install sidekiq
