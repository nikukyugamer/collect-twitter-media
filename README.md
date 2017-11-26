[![CircleCI](https://circleci.com/gh/corselia/collect_twitter_media/tree/master.svg?style=svg)](https://circleci.com/gh/corselia/collect_twitter_media/tree/master) [![codecov](https://codecov.io/gh/corselia/collect_twitter_media/branch/master/graph/badge.svg)](https://codecov.io/gh/corselia/collect_twitter_media) [![Coverage Status](https://coveralls.io/repos/github/corselia/collect_twitter_media/badge.svg)](https://coveralls.io/github/corselia/collect_twitter_media)

# Overview
- You can collect media files (sorry, now image files only except for gif and mp4)
- The source account is yourself (from your home timeline)

# Installation
```ruby
$ gem install collect_twitter_media
```

# Usage

#### 1. require gem
```ruby
require 'collect_twitter_media'
```

#### 2. set your Twitter API token
- collect media files from the acoount belonging to this token

```ruby
CollectTwitterMedia.consumer_key('YOUR_CONSUMER_KEY')
CollectTwitterMedia.consumer_secret('YOUR_CONSUMER_SECRET')
CollectTwitterMedia.access_token('YOUR_ACCESS_TOKEN')
CollectTwitterMedia.access_token_secret('YOUR_ACCESS_TOKEN_SECRET')
```

#### 3. 🎉exec `save` method🎉
- the first argv is the directory name to collect

```ruby
CollectTwitterMedia.save('collect_media')
```

# Options
- the `save` method can take 4 argvs as below
    - the first:  the directory name to collect
    - the second: the collect count of tweet per loop (default: 200)
    - the third:  the loop count to collect media (default: 1)
        - Be careful about `API Rate limits`
    - the fourth: the starting tweet id to collect media (default: the latest)

# Note
- Please, please be careful about `API Rate limits`
    - [Rate limits — Twitter Developers](https://developer.twitter.com/en/docs/basics/rate-limits)
    - [GET statuses/home\_timeline — Twitter Developers](https://developer.twitter.com/en/docs/tweets/timelines/api-reference/get-statuses-home_timeline)

## Development
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/collect_twitter_media.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
