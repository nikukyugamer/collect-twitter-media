RSpec.describe CollectTwitterMedia do
  describe 'gem'
  it "バージョン番号が設定されている" do
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

  describe 'Twitter API クライアント' do
    context 'Key や Token' do
      it 'consumer_key が正しく設定されている' do
        expect(CollectTwitterMedia.consumer_key('ABCDEFGHIJKLMN12345678')).to eq('ABCDEFGHIJKLMN12345678')
      end

      it 'consumer_secret が正しく設定されている' do
        expect(CollectTwitterMedia.consumer_secret('ABCDEFGHIJKLMNOPQRSTUVWXYZ12345678901234')).to eq('ABCDEFGHIJKLMNOPQRSTUVWXYZ12345678901234')
      end

      it 'access_token が正しく設定されている' do
        expect(CollectTwitterMedia.access_token('1234567-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456')).to eq('1234567-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456')
      end

      it 'access_token_secret が正しく設定されている' do
        expect(CollectTwitterMedia.access_token_secret('ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456789')).to eq('ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456789')
      end
    end

    it '正しく定義されている' do
      CollectTwitterMedia.consumer_key('ABCDEFGHIJKLMN12345678')
      CollectTwitterMedia.consumer_secret('ABCDEFGHIJKLMNOPQRSTUVWXYZ12345678901234')
      CollectTwitterMedia.access_token('1234567-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456')
      CollectTwitterMedia.access_token_secret('ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456789')
      expect(CollectTwitterMedia.twitter_client.class).to eq(Twitter::REST::Client)
    end
  end

  describe 'CollectTweetMedia のクラスメソッド' do
    describe 'tweetsオブジェクト' do
      context '#tweet_id_collection' do
        it 'tweet_id_collectionメソッドは、tweetsオブジェクトに含まれているツイートIDを配列で返す' do
          allow(@tweet_mock).to receive(:id)
          expect(CollectTwitterMedia.tweet_id_collection(@tweets_mock).class).to eq(Array)
          expect(CollectTwitterMedia.tweet_id_collection(@tweets_mock).count).to eq(@tweets_mock.count)
        end

        context '#(min|max)_tweet_id' do
          it 'min_tweet_idメソッドは、ツイートIDを要素とする配列から、最小のツイートIDの値を抽出する' do
            expect(CollectTwitterMedia.min_tweet_id(@tweet_id_collection)).to eq('661902288961871871')
          end

          it 'max_tweet_idメソッドは、ツイートIDを要素とする配列から、最大のツイートIDの値を抽出する' do
            expect(CollectTwitterMedia.max_tweet_id(@tweet_id_collection)).to eq('661902288961871875')
          end
        end
      end
    end

    describe 'tweetオブジェクト' do
      context '#original_tweet' do
        it 'tweetオブジェクトがリツイートでないならば返り値は元のtweetオブジェクトである' do
          allow(@tweet_mock).to receive(:retweet?).and_return(false)

          twitter_client_mock = double('Twitter API Client Mock')
          allow(CollectTwitterMedia).to receive(:twitter_client).and_return(twitter_client_mock)

          @client = CollectTwitterMedia.twitter_client
          expect(CollectTwitterMedia.original_tweet(@tweet_mock)).to eq(@tweet_mock)
        end
      end

      context '#media_uris' do
        it 'tweetオブジェクトがメディア（画像、動画）の情報を持っている場合にその情報を返すか' do
          # dirty... should use 'Factory Bot' for instance...
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

          expect((CollectTwitterMedia.media_uris(@tweet_mock))).to eq(expected_return) # Array
        end
      end
    end

    describe '取得したテキストの加工' do
      context "メディア（画像、動画）" do
        it "生の URI から 'original' のサイズのメディアを取得できる URI に変換する" do # TODO: 動画の場合が考慮されていない
          raw_media_uri = 'https://pbs.twimg.com/media/CS-Mn7iW4AA3Tak.png'
          expect(CollectTwitterMedia.media_original_uri(raw_media_uri)).to eq('https://pbs.twimg.com/media/CS-Mn7iW4AA3Tak.png:orig')
        end

        it "ファイル名の部分を抽出する" do
          raw_media_uri = 'https://pbs.twimg.com/media/CS-Mn7iW4AA3Tak.png'
          expect(CollectTwitterMedia.media_filename(raw_media_uri)).to eq('CS-Mn7iW4AA3Tak.png')
        end

        it 'メディアファイルのファイル名の部分を、拡張子を除いて抽出する' do
          image_filename = 'CS-Mn7iW4AA3Tak.png'
          expect(CollectTwitterMedia.basename_of_image_file(image_filename)).to eq('CS-Mn7iW4AA3Tak')
        end
      end

      it 'ツイートしたクライアント名を抽出する' do
        allow(@tweet_mock).to receive(:source).and_return("<a href=\"http://twitter.com\" rel=\"nofollow\">Twitter Web Client</a>")
        expect(CollectTwitterMedia.via_client(@tweet_mock)).to eq('Twitter Web Client')
      end
    end

    describe 'ファイル操作' do
      context '#create_csv_file' do
        it 'CSVファイルが生成される' do
          allow(CSV).to receive(:open).and_return(nil) # not create csv file actually

          save_directory = 'foobar'
          expect(CollectTwitterMedia.create_csv_file(save_directory).match(/#{save_directory}\/image_from_twitter_[0-9]{8}_[0-9]{6}\.csv/).class).to eq(MatchData)
        end
      end

      context '#to_pathname' do
        context '引数' do
          it '単純なディレクトリ名やファイル名の指定ならば、フルパスを返す' do
            pwd   = Pathname.new(Dir.pwd)
            argv  = 'CS-Mn7iW4AA3Tak.png'

            expect(CollectTwitterMedia.to_pathname(argv)).to eq("#{pwd}/#{argv}")
          end

          it '相対ディレクトリ名や相対ファイル名の指定ならば、フルパスを返す' do
            pwd   = Pathname.new(Dir.pwd)
            argv  = 'foo/bar'

            expect(CollectTwitterMedia.to_pathname(argv)).to eq("#{pwd}/#{argv}")
          end

          it '絶対指定ならば、そのままの値を返す' do
            pwd   = Pathname.new(Dir.pwd)
            argv  = '/foo/bar'

            expect(CollectTwitterMedia.to_pathname(argv)).to eq("#{argv}")
          end
        end
      end
    end
  end
end
