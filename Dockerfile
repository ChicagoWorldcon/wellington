# Copyright 2019 James Polley
# Copyright 2019 Steven C Hartley
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
# MailCatcher is incompatible with other gems in bundle development as it uses an older version of rake. So must be installed independently.
# Installing in Dockerfile is temporary fix, as we only want one build target to reduce over head, and we do not want MailCatcher in production.
RUN gem install mailcatcher
CMD bundle exec rails server