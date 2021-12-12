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

FROM ruby:2.7.1-alpine as base

RUN apk add \
      freetds-dev \
      build-base \
      git \
      less \
      netcat-openbsd \
      nodejs \
      nodejs-npm \
      postgresql-client \
      postgresql-dev \
      shared-mime-info \
      sqlite-dev \
      tzdata
RUN npm install -g yarn

WORKDIR /setup

ADD Gemfile /setup/Gemfile
ADD Gemfile.lock /setup/Gemfile.lock
RUN bundle install

ADD yarn.lock /setup/yarn.lock
ADD package.json /setup/package.json
RUN yarn install

FROM ruby:2.7.1-alpine as deploy
RUN apk add \
    nodejs \
    nodejs-npm \
    freetds \
    postgresql-client \
    postgresql \
    shared-mime-info \
    tzdata
RUN npm install -g yarn

ADD . /app

WORKDIR /app

# grab the gems we installed in the base
COPY --from=base /usr/local/bundle /usr/local/bundle

# grab the node modules we installed in the base
COPY --from=base /setup/node_modules /app/node_modules

# we need _a_ worldcon number, for asset precompilation
ARG WORLDCON_NUMBER

# and by default that'll be Chicago :)
ENV WORLDCON_NUMBER ${WORLDCON_NUMBER:-worldcon80}

# precompile our assets
RUN bundle exec rake assets:precompile

# Our launcher
CMD script/docker_web_entry.sh

FROM deploy as test
WORKDIR /app
RUN bundle install --with test

FROM deploy as development
VOLUME /app
WORKDIR /app
RUN bundle install --with test,development
RUN gem install bundler mailcatcher
