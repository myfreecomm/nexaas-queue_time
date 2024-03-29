
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nexaas/queue_time/version"

Gem::Specification.new do |spec|
  spec.name          = "nexaas-queue_time"
  spec.version       = Nexaas::QueueTime::VERSION
  spec.authors       = ["Lucas Mansur"]
  spec.email         = ["lucas.mansur2@gmail.com"]

  spec.summary       = %q{Calculate the amount of time a request has been waiting in the queue}
  spec.homepage      = "https://nexaas.com"
  spec.license       = "MIT"

  spec.metadata      = {
    "source_code_uri" => "https://github.com/myfreecomm/nexaas-queue_time"
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   << 'sidekiq_metric_collector'
  spec.require_paths = ["lib"]

  spec.add_dependency "dogstatsd-ruby", "~> 4.3"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sidekiq", "~> 4"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
end
