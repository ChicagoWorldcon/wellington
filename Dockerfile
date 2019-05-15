# Copyright 2019 James Polley
# Copyright 2019 Matthew B. Gray
# Copyright 2019 Steven C Hartley
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ruby:2.6.1-stretch as base

RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    netcat

# MailCatcher is incompatible with other gems in bundle development as it uses an older version of rake. So must be
# installed independently.
RUN gem install bundler mailcatcher

RUN mkdir /setup
WORKDIR /setup

ADD Gemfile /setup/Gemfile
ADD Gemfile.lock /setup/Gemfile.lock
RUN bundle install

ADD . /app
WORKDIR /app

# Precompile assets for produciton deploy
RUN bundle exec rake assets:precompile

FROM base as development
VOLUME /app

CMD bundle exec rails server -b 0.0.0.0
