require 'collect_twitter_media/version'
require 'collect_twitter_media/file_operation'
require 'twitter'
require 'csv'

module CollectTwitterMedia
  include FileOperation
  extend self

  def save(directory, tweet_count=200, loop_count=1, start_tweet_id='') # HACK: too many argv
    twitter_client
    tweet_collection  = collect_tweets_with_loop(loop_count)
    save_directory    = make_directory_if_not_exist(directory)
    csv_filename      = create_csv_file(save_directory)

    tweet_collection.each do |tweet|
      tweet = original_tweet(tweet) # retweet is NOT correct data, so need to get from original tweet
      save_image_file(save_directory, tweet)
      append_csv_row(csv_filename, tweet)
    end
  end

  # HACK: TOO LONG...（can I use block?)
  def consumer_key(value)
    @consumer_key = value
  end

  def consumer_secret(value)
    @consumer_secret = value
  end

  def access_token(value)
    @access_token = value
  end

  def access_token_secret(value)
    @access_token_secret = value
  end

  def twitter_client
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = @consumer_key
      config.consumer_secret     = @consumer_secret
      config.access_token        = @access_token
      config.access_token_secret = @access_token_secret
    end
  end

  # 'until_tweet_id' is EQUAL OR LESS THAN 'until_tweet_id'
  def collect_tweets(until_tweet_id='', count=200)
    begin
      unless until_tweet_id.is_a?(Integer)
        @client.home_timeline(count: count, include_rts: true, tweet_mode: 'extended')
      else
        @client.home_timeline(count: count, max_id: until_tweet_id, include_rts: true, tweet_mode: 'extended')
      end
    rescue => e
      puts e
      exit(1)
    end
  end

  def collect_tweets_with_loop(loop_count=1, tweet_count=200, start_tweet_id='')
    tweet_collection  = []
    until_tweet_id    = start_tweet_id

    loop_count.times do
      tweets = collect_tweets(until_tweet_id, tweet_count)
      break if tweets.empty?
      tweet_collection << tweets

      next_start_tweet_id = min_tweet_id(tweet_id_collection(tweets)) - 1
      until_tweet_id      = next_start_tweet_id
    end
    tweet_collection.flatten
  end

  def tweet_id_collection(tweets)
    tweet_id_collection = []
    tweets.each do |tweet|
      tweet_id_collection << tweet.id
    end
    tweet_id_collection
  end

  def min_tweet_id(tweet_id_collection)
    tweet_id_collection.min
  end

  def max_tweet_id(tweet_id_collection)
    tweet_id_collection.max
  end

  def media_uris(tweet)
    media_uris = []
    if tweet.media?
      tweet.media.each do |media|
        if media.instance_of?(Twitter::Media::Photo)
          media_uris << media.media_url_https.to_s
        end
      end
    end
    media_uris
  end

  def media_original_uri(media_uri)
    media_original_uri = "#{media_uri}:orig"
  end

  def media_filename(media_uri)
    media_uri.match(/https:\/\/pbs\.twimg\.com\/media\/(.*)\z/)[1] # with extension
  end

  def original_tweet(tweet)
    if tweet.retweet?
      @client.status(tweet.attrs[:retweeted_status][:id], tweet_mode: "extended") # HACK: this occurs be slow response sometimes
    else
      tweet
    end
  end

  def save_image_file(save_directory, tweet)
    media_uri_and_filename(tweet).each do |media_data|
      tweet_id            = media_data['tweet_id']
      media_original_uri  = media_data['media_original_uri']
      media_filename      = media_data['media_filename']
      screen_name         = media_data['screen_name']

      command = "wget -q #{media_original_uri} -O #{save_directory}/@#{screen_name}_#{tweet_id}_#{media_filename}"
      `#{command}`
    end
  end

  # if several attachment image files exist, we save all ones
  def media_uri_and_filename(tweet)
    media_uri_and_filename = []
    media_uris(tweet).each do |media_uri|
      insert = {}
      insert['tweet_id']            = tweet.id
      insert['media_original_uri']  = media_original_uri(media_uri)
      insert['media_filename']      = media_filename(media_uri)
      insert['screen_name']         = tweet.attrs[:user][:screen_name]
      insert['created_at']          = tweet.created_at

      media_uri_and_filename << insert
    end
    media_uri_and_filename
  end

  def create_csv_file(save_directory, base_filename='image_from_twitter')
    now_time = Time.now.strftime("%Y%m%d_%H%M%S")
    filename = "#{save_directory}/#{base_filename}_#{now_time}.csv"
    header = [
      'tweet_id',
      'screen_name',
      'original_filename',
      'save_filename',
      'uri',
      'created_at',
    ]
    CSV.open(filename, 'w') do |csv_file|
      csv_file << header
    end

    filename
  end

  # HACK: 'media_uri_and_filename' method is duplicated in 'save_image_file' method
  def append_csv_row(csv_filename, tweet)
    media_uri_and_filename(tweet).each do |media_data|
      row = [
        media_data['tweet_id'],
        media_data['screen_name'],
        media_data['media_filename'],
        "@#{media_data['screen_name']}_#{media_data['tweet_id']}_#{media_data['media_filename']}",
        media_data['media_original_uri'],
        media_data['created_at'],
      ]

      CSV.open(csv_filename, 'a') do |csv_file|
        csv_file << row
      end
    end
  end

  # deprecated method because when tweet is retweet it doesn't work correctly
  def media_uris_and_filenames(tweets)
    media_uris_and_filenames = []
    tweets.each do |tweet|
      media_uris_and_filenames << media_uri_and_filename(tweet)
    end
    media_uris_and_filenames.flatten
  end

  # not used
  def via_client(tweet)
    source = tweet.source # ex. "<a href=\"http://twitter.com\" rel=\"nofollow\">Twitter Web Client</a>"
    source.match(/\A<a href=".*>(.*)<\/a>\z/)[1]
  end
end
