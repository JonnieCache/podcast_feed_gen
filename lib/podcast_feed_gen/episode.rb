require "podcast_feed_gen/generator"
require 'digest'
require 'taglib'

module PodcastFeedGen
  class Episode
    attr_reader :values
    
    def initialize(path, config)
      @config = config
      
      filename = File.basename path
      ext  = File.extname path
      
      TagLib::FileRef.open(path) do |fileref|
        t = fileref.tag
        p = fileref.audio_properties
        
        nilify = ->(s){ s == "" ? nil : s }

        @values = {
          filename: filename,
          title: nilify[t.title] || filename,
          author: nilify[t.artist],
          description: nilify[t.comment] || filename,
          duration: duration(p.length),
          date: File.mtime(path),
          size: File.size(path),
          mime_type: Generator::FILETYPES[ext],
          sha256: Digest::SHA256.hexdigest(File.read(path)),
          url: @config[:base_url] + filename
        }.freeze
      end
    end
    
    def [](key)
      @values[key]
    end
    
    private
    
    def duration(seconds)
      return nil if seconds.nil?
      
      "%02d:%02d:%02d" % [seconds/3600%24, seconds/60%60, seconds%60]
    end
    
  end
end
