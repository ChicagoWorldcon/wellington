# Copyright 2019 James Polley
FROM ruby:2.6.1-stretch as base

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
    build-essential \
    libpq-dev
RUN gem install bundler

RUN mkdir /setup
WORKDIR /setup

ADD Gemfile /setup/Gemfile
ADD Gemfile.lock /setup/Gemfile.lock
RUN bundle install

ADD . /app
WORKDIR /app

FROM base as development
VOLUME /app
RUN gem install mailcatcher
CMD bundle exec rails server

