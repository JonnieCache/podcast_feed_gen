require 'podcast_feed_gen/generator'

module PodcastFeedGen
  RSpec.describe Generator do
    let(:time) {Time.new(2018,10,11,1,1,1, "+01:00")}
    context 'with hardcoded config' do
      let(:config) do
        {
          base_url: 'http://example.com/podcast/',
          title: 'test feed',
          author: 'John Doe',
          description: 'lmao'
        }
      end
      let(:gen) { Generator.new(working_dir: support_path('mp3s'), config: config) }
      
      it "outputs the correct xml" do
        expect(gen.gen!).to eq File.read support_path('mp3s.rss')
      end
    end
    
    context 'with config file' do
      let(:gen) { Generator.new(working_dir: support_path('mp3s')) }
      before do
        config = <<~YAML
          base_url: http://example.com/podcast/
          title: test feed
          author: John Doe
          description: lmao
        YAML
        File.write(support_path('mp3s', 'podcast_feed_gen.yml'), config)
      end
      
      it "outputs the correct xml" do
        expect(gen.gen!).to eq File.read support_path('mp3s.rss')
      end
      
      context 'run from the command line' do
        it "outputs the correct xml" do
          bin_path = File.join PROJECT_ROOT, 'exe', 'podcast_feed_gen'
          
          rss = `cd #{support_path('mp3s')} && #{bin_path}`
          
          expect(rss).to eq File.read support_path('mp3s.rss')
        end
      end
    end
    
  end
end
