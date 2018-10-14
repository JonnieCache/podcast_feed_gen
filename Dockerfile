FROM alpine:3.8

RUN mkdir -p /etc \
  && { \
    echo 'install: --no-document'; \
    echo 'update: --no-document'; \
  } >> /etc/gemrc

RUN apk add --no-cache -u \
  ruby \
  tzdata \
  git \
  taglib-dev \
  ruby-dev \
  ruby-etc \
  ruby-irb \
  libxml2-dev \
  build-base \
  libxslt-dev

RUN ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

RUN gem install bundler
RUN bundle config --global silence_root_warning 1

WORKDIR /tmp 
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
ADD podcast_feed_gen.gemspec podcast_feed_gen.gemspec
ADD lib/podcast_feed_gen/version.rb lib/podcast_feed_gen/version.rb
RUN bundle install 

ADD . /podcast_feed_gen

WORKDIR /podcast_feed_gen

CMD exe/podcast_feed_gen
