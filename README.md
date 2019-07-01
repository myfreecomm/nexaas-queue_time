[![Build Status](https://travis-ci.org/myfreecomm/nexaas-queue_time.svg?branch=master)](https://travis-ci.org/myfreecomm/nexaas-queue_time)
# Nexaas::QueueTime


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nexaas-queue_time'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nexaas-queue_time

## Usage

### Rails initialization
Add this gem to the Middleware stack before `Rack::Runtime`, like this:

```ruby
require "nexaas/queue_time/middleware"
config.middleware.insert_before Rack::Runtime, Nexaas::QueueTime::Middleware
```
You can place it in `config/application.rb` or in a specific environment file, such as `config/environments/production.rb`

This code can also be placed in an initializer file, such as `config/initializers/middlewares.rb`:
```ruby
Rails.env.on(:any) do |config|
  require "nexaas/queue_time/middleware"
  config.middleware.insert_before Rack::Runtime, Nexaas::QueueTime::Middleware
end
```

### Header requirement
For the gem to work, someone **must** set the header `X-Request-Start` with the format `t=timestamp`, where `timestamp` is the UNIX timestamp.
This someone could be a load balancer, reverse proxy or router. Heroku already does that for you automatically.

### DogStatsD

After calculating the `queue_time`, this gem sends it to a [DogStatsD](https://docs.datadoghq.com/developers/dogstatsd/) server via [UDS](https://en.wikipedia.org/wiki/Unix_domain_socket).

Without the _DogStatsD_ agent this gem is pretty much useless.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/myfreecomm/nexaas-queue_time.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
