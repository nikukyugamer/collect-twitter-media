
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "collect_twitter_media/version"

Gem::Specification.new do |spec|
  spec.name          = "collect_twitter_media"
  spec.version       = CollectTwitterMedia::VERSION
  spec.authors       = ["Osamu Takiya"]
  spec.email         = ["takiya@toran.sakura.ne.jp"]

  spec.summary       = %q{Collect media files from Twitter}
  spec.description   = %q{you can collect the media files such as .jpg, .png ... from Twitter's timeline}
  spec.homepage      = "https://github.com/corselia/collect-twitter-media"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency 'twitter'
end
