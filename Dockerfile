# Copyright 2019 James Polley
# Copyright 2019 Steven C Hartley
# Copyright 2020 Matthew B. Gray
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

FROM ruby:2.6.5-alpine as base

RUN apk add \
      build-base \
      git \
      netcat-openbsd \
      nodejs \
      nodejs-npm \
      postgresql-client \
      postgresql-dev \
      sqlite-dev \
      tzdata \
    && rm -rf /var/cache/apk/* \
    && npm install -g yarn \
    && gem install bundler mailcatcher

# n.b, MailCatcher is incompatible with other gems in bundle

RUN mkdir /setup
WORKDIR /setup

ADD Gemfile /setup/Gemfile
ADD Gemfile.lock /setup/Gemfile.lock
RUN bundle install

ADD yarn.lock /setup/yarn.lock
ADD package.json /setup/package.json
RUN yarn install

ADD . /app
WORKDIR /app

RUN mv /setup/node_modules ./node_modules \
    && bundle exec rake assets:precompile

FROM base as development
VOLUME /app

CMD script/docker_web_entry.sh
