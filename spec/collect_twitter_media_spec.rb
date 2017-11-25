RSpec.describe CollectTwitterMedia do
  it "has a version number" do
    expect(CollectTwitterMedia::VERSION).not_to be nil
  end

  context 'Twitter API クライアント の定義' do
    it 'define consumer_key' do
      expect(CollectTwitterMedia.consumer_key('ABCDEFGHIJKLMN12345678')).to eq('ABCDEFGHIJKLMN12345678')
    end

    it 'define consumer_secret' do
      expect(CollectTwitterMedia.consumer_secret('ABCDEFGHIJKLMNOPQRSTUVWXYZ12345678901234')).to eq('ABCDEFGHIJKLMNOPQRSTUVWXYZ12345678901234')
    end

    it 'define access_token' do
      expect(CollectTwitterMedia.access_token('1234567-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456')).to eq('1234567-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456')
    end

    it 'define access_token_secret' do
      expect(CollectTwitterMedia.access_token_secret('ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456789')).to eq('ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456789')
    end

    it 'define Twitter API client' do
      CollectTwitterMedia.consumer_key('ABCDEFGHIJKLMN12345678')
      CollectTwitterMedia.consumer_secret('ABCDEFGHIJKLMNOPQRSTUVWXYZ12345678901234')
      CollectTwitterMedia.access_token('1234567-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456')
      CollectTwitterMedia.access_token_secret('ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890123456789')
      expect(CollectTwitterMedia.send(:twitter_client).class).to eq(Twitter::REST::Client)
    end
  end

  context 'REST API で取得できる値が正しいか？' do
    it 'via_client' do
      tweet = double('tweet object of twitter gem')
      allow(tweet).to receive(:source).and_return("<a href=\"http://twitter.com\" rel=\"nofollow\">Twitter Web Client</a>")
      expect(CollectTwitterMedia.send(:via_client, tweet)).to eq('Twitter Web Client')
    end
  end
end
