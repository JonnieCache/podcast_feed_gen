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
      parser(ext).open(path) do |fileref|
        tag = fileref.tag
        audio_props = fileref.audio_properties

        @values = {
          filename: filename,
          title: nilify_string(tag.title) || filename,
          author: nilify_string(tag.artist),
          description: nilify_string(tag.comment) || filename,
          duration: duration(audio_props.length_in_seconds),
          date: File.mtime(path),
          size: File.size(path),
          mime_type: Generator::FILETYPES[ext],
          sha256: Digest::SHA256.hexdigest(File.read(path)),
          url: @config[:base_url] + filename,
          cover_url: extract_cover(fileref, path),
        }.freeze
      end
    end

    def [](key)
      @values[key]
    end

    private

    def parser(ext)
      case ext
      when '.mp3'
        TagLib::MPEG::File
      else
        TagLib::FileRef
      end
    end

    def extract_cover(file, path)
      return unless file.is_a?(TagLib::MPEG::File)

      tag = file.id3v2_tag
      cover = tag.frame_list('APIC').first
      return unless cover

      image_ext = case cover.mime_type
      when 'image/jpeg'
        'jpg'
      when 'image/png'
        'png'
      else
        raise StandardError, "Unknown MP3 cover art mime-type: #{cover.mime_type}"
      end
      image_filename = "#{Digest::SHA256.hexdigest(File.read(path))}.#{image_ext}"
      image_path = path.sub(File.basename(path), image_filename)
      File.write(image_path, cover.picture)
      @config[:base_url] + image_filename
    end

    def nilify_string(s)
      s == "" ? nil : s
    end

    def duration(seconds)
      return nil if seconds.nil?

      "%02d:%02d:%02d" % [seconds/3600%24, seconds/60%60, seconds%60]
    end
  end
end
