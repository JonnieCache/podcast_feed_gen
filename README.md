# podcast_feed_gen

A simple CLI app for generating podcast RSS feeds from a directory of files. Similar to [dropcaster](https://github.com/nerab/dropcaster) but much simpler, and it supports a wide variety of audio formats instead of just MP3.

The idea is to put a directory containing some audio files somewhere publically accessible over http, (dropbox works well) and then run this program to generate an RSS file, which can then be consumed by your podcast playing app of choice.

Episode dates are read from the last-modified times of the files, and Title and Description fields are taken from the episode tags.

## Installation

Install taglib with your OS's package manager:

Ubuntu/Debian:

    $ apt-get install libtag1-dev
    
Fedora/RHEL:

    $ yum install taglib-devel

MacOS:

    $ brew install taglib
    
Then install podcast_feed_gen:

    $ gem install podcast_feed_gen

## Usage

Assemble the aformentioned publically accesible directory of episodes, and then place a file called `podcast_feed_gen.yml` in there with content like so:

```
base_url: http://example.com/podcast/
title: test feed
author: John Doe
description: A cool podcast
```

The `base_url` value is most important, it's the public facing URL of the directory, and it needs to have a slash at the end.

Then just run the script:

    $ podcast_feed_gen
    
This will output the rss to stdout. Verify that it's as you expected, and then write it to an rss file:

    $ podcast_feed_gen > index.rss

Then add the public URL of this file to your podcast player, and off you go. To update the feed, just put some more files into the directory and run the script again.

## TODO

1. Support for artwork, arbitrarily defined in the case of the channel and extracted from tag metadata for the episodes.
2. Better configurability, eg. support for reading the configuration file from a path specified on the command line.
3. Overriding the episode metadata with values taken from the config file.

## Development

podcast_feed_gen is written in ruby. We've got some rspec tests, we've got a `Dockerfile`, and we've got a [TinyCI](https://github.com/JonnieCache/tinyci) config.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/JonnieCache/podcast_feed_gen

## License

Open Source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
