RSpec.describe CollectTwitterMedia do
  it "has a version number" do
    expect(CollectTwitterMedia::VERSION).not_to be nil
  end

  before do
    @tweet_mock = double('tweet object of twitter gem')
    @tweets_mock = []
    10.times do
      @tweets_mock << @tweet_mock
    end

    @tweet_media_photo_mock = double('tweet media photo object of twitter gem')

    # should use 'Factory Bot'...
    @tweet_id_collection = [
      '661902288961871871',
      '661902288961871872',
      '661902288961871873',
      '661902288961871874',
      '661902288961871875',
    ]
  end

  describe 'Define Twitter API client' do
    it 'Define consumer_key' do
      expect(CollectTwitterMedia.consumer_key('ABCDEFGHIJKLMN12345678')).to eq('ABCDEFGHIJKLMN12345678')
    end

    it 'Define consumer_secret' do
      expect(CollectTwitterMedia.consumer_secret('ABCDEFGHIJKLMNOPQRSTUVWXYZ12345678901234')).to eq('ABCDEFGHIJKLMNOPQRSTUVWXYZ12345678901234')
    end

    it 'Define access_token' do
      expect(CollectTwitterMedia.access_token('1234567-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456')).to eq('1234567-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456')
    end

    it 'Define access_token_secret' do
      expect(CollectTwitterMedia.access_token_secret('ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456789')).to eq('ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456789')
    end

    it 'Define Twitter API client' do
      CollectTwitterMedia.consumer_key('ABCDEFGHIJKLMN12345678')
      CollectTwitterMedia.consumer_secret('ABCDEFGHIJKLMNOPQRSTUVWXYZ12345678901234')
      CollectTwitterMedia.access_token('1234567-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456')
      CollectTwitterMedia.access_token_secret('ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456789')
      expect(CollectTwitterMedia.twitter_client.class).to eq(Twitter::REST::Client)
    end
  end

  describe 'Access to Twitter API' do
  end

  describe 'Operation to tweets object' do
    it 'Tweet_id_collection' do
      allow(@tweet_mock).to receive(:id).and_return('661902288961871873')
      expect(CollectTwitterMedia.tweet_id_collection(@tweets_mock).class).to eq(Array)
      expect(CollectTwitterMedia.tweet_id_collection(@tweets_mock).count).to eq(@tweets_mock.count)
    end

    it 'Min_tweet_id' do
      expect(CollectTwitterMedia.min_tweet_id(@tweet_id_collection)).to eq('661902288961871871')
    end

    it 'Max_tweet_id' do
      expect(CollectTwitterMedia.max_tweet_id(@tweet_id_collection)).to eq('661902288961871875')
    end

    context 'Replace retweet to original tweet' do
      it 'Is original tweet' do
        allow(@tweet_mock).to receive(:retweet?).and_return(false)

        twitter_client_mock = double('Twitter API Client Mock')
        allow(CollectTwitterMedia).to receive(:twitter_client).and_return(twitter_client_mock)

        @client = CollectTwitterMedia.twitter_client
        expect(CollectTwitterMedia.original_tweet(@tweet_mock)).to eq(@tweet_mock)
      end

      # TODO: write
      # it 'Is retweet' do
      #   allow(@tweet_mock).to receive(:retweet?).and_return(true)
      # end
    end

    context 'Retrieve uris with media' do
      it 'Uri with media' do
        # dirty... should use 'Factory Bot'...
        media = [
          @tweet_media_photo_mock,
          @tweet_media_photo_mock,
          @tweet_media_photo_mock,
          @tweet_media_photo_mock,
        ]
        return_uri = 'https://pbs.twimg.com/media/CS-Mn7iW4AA3Tak.png'
        expected_return = [
          return_uri,
          return_uri,
          return_uri,
          return_uri,
        ]

        allow(@tweet_mock).to receive('media?').and_return(true)
        allow(@tweet_mock).to receive(:media).and_return(media)
        allow(@tweet_media_photo_mock).to receive('instance_of?').with(Twitter::Media::Photo).and_return(true)
        allow(@tweet_media_photo_mock).to receive(:media_url_https).and_return(return_uri)

        expect((CollectTwitterMedia.media_uris(@tweet_mock))).to eq(expected_return)
      end

      # it 'Uri without media' do
        # TODO: write
      # end
    end
  end

  describe 'Exchange text to text' do
    it "Exchange 'raw' media uri to 'original' media uri" do
      raw_media_uri = 'https://pbs.twimg.com/media/CS-Mn7iW4AA3Tak.png'
      expect(CollectTwitterMedia.media_original_uri(raw_media_uri)).to eq('https://pbs.twimg.com/media/CS-Mn7iW4AA3Tak.png:orig')
    end

    it "Exchange 'raw' media uri to media filename with extension" do
      raw_media_uri = 'https://pbs.twimg.com/media/CS-Mn7iW4AA3Tak.png'
      expect(CollectTwitterMedia.media_filename(raw_media_uri)).to eq('CS-Mn7iW4AA3Tak.png')
    end
  end

  describe 'JSON from REST API is correct?' do
    it 'Via_client' do
      allow(@tweet_mock).to receive(:source).and_return("<a href=\"http://twitter.com\" rel=\"nofollow\">Twitter Web Client</a>")
      expect(CollectTwitterMedia.via_client(@tweet_mock)).to eq('Twitter Web Client')
    end

    it 'Tweet_id_collection' do
      allow(@tweet_mock).to receive(:id).and_return('661902288961871873')
      expect(CollectTwitterMedia.tweet_id_collection(@tweets_mock).class).to eq(Array)
      expect(CollectTwitterMedia.tweet_id_collection(@tweets_mock).count).to eq(@tweets_mock.count)
    end
  end

  describe 'file_operation' do
    it 'create CSV file' do
      allow(CSV).to receive(:open).and_return(nil) # not create csv file actually

      save_directory = 'foobar'
      expect(CollectTwitterMedia.create_csv_file(save_directory).match(/#{save_directory}\/image_from_twitter_[0-9]{8}_[0-9]{6}\.csv/).class).to eq(MatchData)
    end

    it 'basename_of_image_file' do
      image_filename = 'CS-Mn7iW4AA3Tak.png'
      expect(CollectTwitterMedia.basename_of_image_file(image_filename)).to eq('CS-Mn7iW4AA3Tak')
    end

    # TODO: write
    # it 'remove_image' do
    # end

    context 'to_pathname' do
      it 'argv is filename' do
        pwd = Pathname.new(Dir.pwd)
        argv = 'CS-Mn7iW4AA3Tak.png'

        expect(CollectTwitterMedia.to_pathname(argv)).to eq("#{pwd}/#{argv}")
      end

      it 'argv is relative directory name' do
        pwd = Pathname.new(Dir.pwd)
        argv = 'foo/bar'

        expect(CollectTwitterMedia.to_pathname(argv)).to eq("#{pwd}/#{argv}")
      end

      it 'argv is absolute directory name' do
        pwd = Pathname.new(Dir.pwd)
        argv = '/foo/bar'

        expect(CollectTwitterMedia.to_pathname(argv)).to eq("#{argv}")
      end

      it 'argv is directory name or filename' do
        pwd = Pathname.new(Dir.pwd)
        argv = 'foo'

        expect(CollectTwitterMedia.to_pathname(argv)).to eq("#{pwd}/#{argv}")
      end
    end
  end
end
