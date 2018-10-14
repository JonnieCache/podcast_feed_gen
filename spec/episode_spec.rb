require 'podcast_feed_gen/episode'

module PodcastFeedGen
  RSpec.describe Episode do
    context 'with id3 tags' do
      let(:config) do
        {
          base_url: 'http://example.com/podcast/',
          title: 'test feed',
          author: 'John Doe',
          description: 'lmao'
        }
      end
      let(:gen) { Generator.new(working_dir: support_path('with_tags'), config: config) }
      
      it "outputs the correct xml" do
        expect(gen.gen!).to eq File.read support_path('with_tags.rss')
      end
    end
  end
end
