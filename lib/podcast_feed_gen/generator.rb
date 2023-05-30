require "podcast_feed_gen/version"
require "podcast_feed_gen/episode"
require "symbolize"
require 'time'
require 'nokogiri'
require 'yaml'

module PodcastFeedGen
  class Generator
    include Symbolize
    
    FILETYPES = {
      '.mp3'  => 'audio/mpeg',
      '.m4a'  => 'audio/m4a',
      '.ogg'  => 'audio/ogg',
      '.oga'  => 'audio/ogg',
      '.flac' => 'audio/flac'
    }
    
    def initialize(working_dir: '.', config: nil)
      @working_dir = File.expand_path working_dir
      @config = config || load_config
    end
    
    def gen!
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.rss :version => "2.0", "xmlns:itunes" => "http://www.itunes.com/dtds/podcast-1.0.dtd",  "xmlns:media" => "http://search.yahoo.com/mrss/", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
          xml.channel do
            xml.tag!("atom:link",  "href" => feed_url, "rel"=>"self", "type"=>"application/rss+xml") 
            xml.title @config[:title]
            xml.link feed_url
            xml.description @config[:description]
            xml.language 'en'
            xml.pubDate episodes.first[:date].rfc822
            xml.lastBuildDate episodes.first[:date].rfc822
            xml.link @config[:link] if @config[:link]
            xml['itunes'].author @config[:author]
            xml.copyright "Copyright #{Time.now.year} #{@config[:author]}" if @config[:copyright]
            xml['itunes'].keywords @config[:keywords] if @config[:keywords]
            xml['itunes'].explicit @config[:explicit] if @config[:explicit]
            # xml['itunes'].image :href => @config[:image_url]
            xml['itunes'].owner do
              xml['itunes'].name @config[:author] if @config[:author]
              xml['itunes'].email @config[:email] if @config[:email]
            end if @config[:author]
            
            xml['itunes'].block 'no'
            if @config[:category]
              xml['itunes'].category :text => @config[:category]
            end

            episodes.each do |episode|
              xml.item do
                xml.title episode[:title]
                xml.description episode[:description]
                xml.pubDate episode[:date].rfc822
                xml.enclosure :url => episode[:url], :length => episode[:size], :type => episode[:mime_type]
                xml.link episode[:url]
                xml.guid({:isPermaLink => "false"}, episode[:sha256])
                xml['itunes'].author episode[:author] || @config[:author]
                xml['itunes'].summary episode[:description]
                xml['itunes'].explicit 'no'
                xml['itunes'].duration episode[:duration] if episode[:duration]
              end
            end
          end
        end
      end
      
      builder.to_xml
      
    end
    
    private
    
    def episodes
      files = Dir.entries(@working_dir).select {|e| FILETYPES.keys.any? {|f| e.end_with? f }}
      
      files.map do |filename|
        path = File.join @working_dir, filename
        Episode.new(path, @config)
      end.sort_by {|e| e[:date]}
      
    end
    
    def feed_url
      @config[:base_url] + 'index.rss'
    end
    
    def load_config
      config_path = File.join @working_dir, 'podcast_feed_gen.yml'
      
      unless File.exist? config_path
        puts "config file '#{config_path}' not found"
        
        exit 1
      end
      
      symbolize YAML.safe_load(File.read(config_path))
    end
  end
end
