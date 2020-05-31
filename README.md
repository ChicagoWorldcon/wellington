# Worldcon Members Management

Kia ora and welcome to the [2020-wellington](https://gitlab.com/worldcon/2020-wellington) source code repository. This
site hosts and tracks changes to code for managing Members of the [CoNZealand](https://conzealand.nz/) convention.

What you'll find in this project is a series of compromises that we felt struck a balance with features and
functionality. If you have an interest in making your convention or future conventions better do feel free to reach out
by [raising an issue](https://gitlab.com/worldcon/2020-wellington/issues/new) and we'll be happy to talk it over.

[![pipeline status](https://gitlab.com/worldcon/2020-wellington/badges/master/pipeline.svg)](https://gitlab.com/worldcon/2020-wellington/commits/master)
[![coverage report](https://gitlab.com/worldcon/2020-wellington/badges/master/coverage.svg)](https://gitlab.com/worldcon/2020-wellington/commits/master)

# Changelog and Versioning

All notable changes to this project will be documented in [our changelog](CHANGELOG.md).

We maintain published docker images for this project in our
[container registry](https://gitlab.com/worldcon/2020-wellington/container_registry). These track
* all branches that ran through CI including master
* all tags on the project which follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
* `:latest` tracks master which moves after things have gone through code review and basic testing
* `:stable` tracks latest tags and update after a new tag is pushed

# Contacting Us and Contributing

You can contact us by [raising an issue](https://gitlab.com/worldcon/2020-wellington/issues/new) in our tracker.

If you want it to be private, there's a checkbox that marks the issue as *confidential* which will only be visible to
team members. This is particularly important if you need to disclose a security issue, please let us know in confidence
to respect our member's privacy and rights.

If you'd like to contribute, please read our [Contribution Guidelines](CONTRIBUTING.md).

We've got a [Good First Issue](https://gitlab.com/worldcon/2020-wellington/issues?label_name%5B%5D=Good+First+Issue)
label on issues that we feel are valuable to the project, but also a good size for people just starting out. If you're
keen have a look at this list and leave comments on any you'd like to try.

# Getting Started

This project is a super standard Ruby on Rails application that runs on Postgres and Redis. There's a really simple
[OSX guide](OSX.md) guide for those that use it as their daily driver.

However to try make on-boarding for people who are just starting Ruby or want a simpler setup to manage, we've got
methods to run inside Docker and Docker Compose. This simplifies setup and testing and is really easy to clean up when
you're done. These steps rely on GNU Make for common commands, and git to track your project files.

If you run into troubles getting any of this working, ask for help by
[raising an issue](https://gitlab.com/worldcon/2020-wellington/issues/new) and we'll be in touch!

From here onwards, we're assuming you're comfortable running commands in your console. These commands will create and install
files on your machine.

If you haven't already, please install:
1. [docker and docker-compose](https://docs.docker.com/compose/install/),
2. [gnu make](https://www.gnu.org/software/make/),
3. and [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).

Once you have these, clone this project using the git clone command with the URL you get from the clone button on the
top right of the page.

If you've been following or are planning to follow the [Contribution Guidelines](CONTRIBUTING.md), make sure you use the
clone button on your fork of this project.

The command you run will end up looking something like this:

```sh
git clone git@gitlab.com:worldcon/2020-wellington.git worldcon_members_area
```

This will create a directory named `worldcon_members_area` which you should run all the following commands from.

```sh
cd worldcon_members_area
```

You're going to need to setup a `.env` file to run this project. This is just a text file, and will keep your
configuration secrets out of source control. Here's an example to get you started!

```sh
# FQDN of the machine that's running the members area
HOSTNAME=localhost:3000

# Stripe keys for payment
# Generate them here https://dashboard.stripe.com/account/apikeys
STRIPE_PUBLIC_KEY=pk_test_zq022DcopypastatXAVMaOJT
STRIPE_PRIVATE_KEY=sk_test_35SiP3qovcopypastaLguIyY
# https://stripe.com/docs/currencies
STRIPE_CURRENCY=NZD

# Con specific mailer configuration
MAINTAINER_EMAIL=your.name@conzealand.nz
MEMBER_SERVICES_EMAIL=registrations@conzealand.nz

# Reporting, if you don't set these they don't send
NOMINATION_REPORTS_EMAIL=hugo-help@conzealand.nz
MEMBERSHIP_REPORTS_EMAIL=registrations@conzealand.nz

# Auth secrets, make sure they're super hard to guess!
JWT_SECRET=838734faa9b935c1f8b68846e37aed9096cc9fb746copypastaf856594409a11b1086535e468edb2e5bbc18482b386b6264ada38703dcdefd94a291ab5a95eb5
DEVISE_SECRET=838734faa9b935c1f8b68846e37aed9096cc9fb746copypastaf856594409a11b1086535e468edb2e5bbc18482b386b6264ada38703dcdefd94a291ab5a95eb5

# Times when the Hugo Nominations and Voting pages will become active for members
HUGO_NOMINATIONS_OPEN_AT=2019-12-31T23:59:00-08:00
HUGO_VOTING_OPEN_AT=2020-03-13T11:59:00-08:00
HUGO_CLOSED_AT=2020-08-02T12:00:00+13:00

# Instalment amounts for users to choose from
# If not specified, defaults to $75 and $50
INSTALMENT_MIN_PAYMENT_CENTS=7500
INSTALMENT_PAYMENT_STEP_CENTS=5000

# Postgres default values
DB_HOST=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=secretcopypasta

# Sidekiq is a background task manager which you can view on /sidekiq
# Setting SIDEKIQ_NO_PASSWORD means you can hit this URL without basicauth
SIDEKIQ_REDIS_URL=redis://redis:6379/0
SIDEKIQ_NO_PASSWORD=true
# SIDEKIQ_USER=sidekiq
# SIDEKIQ_PASSWORD=5b197341fc62d9c9bbcopypastabc7a6cbcf07329c9fe52fa55cab98e

# Uncomment to reset database on start up, good for switching branches when patches are present
# NAPALM=true
```

If you're on production, please replace fields with your own values or the application will explode with copy pasta
errors ;-)

Now start your server with

```sh
make start
```

Changes you make to your machine will show up inside the application which you can browse from http://localhost:3000

All emails sent from the website will be caught and displayed from http://localhost:1080, including login links and
receipts.

If you want to run up a console so you can get a seeded user with dummy reservations, you can do this with:

```sh
make console
User.all.sample.email
```

A default support user is created as part of seeds. You should be able to sign in as this user by

1. navigating to http://localhost:3000/supports/sign_in
2. signing in with "support@worldcon.org", password 111111

If you need to install or upgrade dependencies, you can get a shell in your environment to run those commands

```sh
make shell
yarn upgrade
bundle update
```

If you want to run tests for the project you can do this by running

```sh
make test
```

If you've finished working and want to shut down the servers, run

```sh
make stop
```

You can also run your own commands in the container itself. Check out the Makefile for examples of how you might do
this. Here are some examples to get you started:

```sh
# Generate migrations
# see https://guides.rubyonrails.org/active_record_migrations.html
docker-compose exec members_area bundle exec rails generate migration

# Install a gem you've added to the project's Gemfile
docker-compose exec members_area bundle install

# Run migrations after changing branches
docker-compose exec members_area bundle exec rake db:migrate
```

If you want to quickly reset your javascript dependencies and database, you can do this by setting
`NAPALM=true` in your .env and restarting your database.

You can go a step further and drop the disks backing those containers:

```sh
make reset
```

Or you can go all the way and remove the docker containers, disks and networks:

```sh
make clean
```

From here you can delete the project files if you're done, or just run `make start` and everything will be built again
from scratch.

# Running in Production

We're taking advantage of Gitlab's CI pipeline to build docker images. You can browse our
[list of images](https://gitlab.com/worldcon/2020-wellington/container_registry)
or just follow the `:latest` tag to get things that have gone through CI and code review.

To see all versions available, check out our [container registry](https://gitlab.com/worldcon/2020-wellington/container_registry).
Git tags move `:stable`, merged work that's passed review moves `:latest`.

Below is an example setup which should get you most of the way towards a running instance.

CoNZealand has a few URLs, one for stable and one for master. Because staging traffic is minimal, the rails servers are
loaded onto the same AWS EC2 t2.micro instance using Ubuntu with
[docker-compose](https://docs.docker.com/compose/install/). Our database concerns are served by an AWS RDS db.t2.micro
which handles patching, backups and maintenance.

For an easy setup with SSL, conzealand uses [Caddy](https://caddyserver.com/) because it handles SSL with
[Lets Encrypt](https://letsencrypt.org/) and is fairly quick.

Here's the CoNZealand compose file:

`~/docker-compose`
```yaml
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

version: '3.6'

services:
  ingress:
    image: "abiosoft/caddy"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/Caddyfile:ro
      - ssl-certs:/root/.caddy:rw
    environment:
      # https://github.com/abiosoft/caddy-docker#lets-encrypt-subscriber-agreement
      ACME_AGREE: "true"
    restart: always

  redis:
    image: redis:alpine
    restart: always
    volumes:
      - redis-data:/data

  production_web:
    env_file:
      production.env
    image: registry.gitlab.com/worldcon/2020-wellington:stable
    restart: always
    volumes:
      - type: tmpfs
        target: /app/tmp

  production_worker:
    entrypoint: "script/docker_sidekiq_entry.sh"
    image: registry.gitlab.com/worldcon/2020-wellington:stable
    env_file:
      production.env
    restart: always
    volumes:
      - type: tmpfs
        target: /app/tmp

  staging_web:
    env_file:
      staging.env
    image: registry.gitlab.com/worldcon/2020-wellington:latest
    restart: always
    volumes:
      - type: tmpfs
        target: /app/tmp

  staging_worker:
    entrypoint: "script/docker_sidekiq_entry.sh"
    image: registry.gitlab.com/worldcon/2020-wellington:latest
    env_file:
      production.env
    restart: always
    volumes:
      - type: tmpfs
        target: /app/tmp

volumes:
  ssl-certs:
  redis-data:
```

Here's the Cadyfile which handles SSL termination, transparent forwarding to our rails servers and http basic auth for
our staging setup:

`~/Cadyfile`
```
members.conzealand.nz {
  log stdout
  errors stdout
  proxy / production_web:3000 {
    transparent
  }
}

members-staging.conzealand.nz {
  log stdout
  errors stdout
  basicauth / preview "yolo super secret password"
  proxy / staging_web:3000 {
    transparent
  }
}
```

For Cadfyile options, see [Cadyfile reference](https://caddyserver.com/v1/tutorial/caddyfile).

If you're interested in the docker image configuration options, see [abiosoft/caddy](https://hub.docker.com/r/abiosoft/caddy)

Here's a version of our production config with production specific environment variables and obscured secrets:

`production.env`
```bash
# Used for URL generation and using compiled assets
RAILS_ENV=production

HOSTNAME=members.conzealand.nz
RAILS_ENV=production

# DB_NAME will be used in rake tasks to stand up your database, so use whatever you prefer here
# Settings taken from https://console.aws.amazon.com/rds/home
DB_HOST=mydatabasepasta.lecopypastah.ap-southeast-2.rds.amazonaws.com
DB_NAME=worldcon_production
POSTGRES_USER=postgres
POSTGRES_PASSWORD=shuquairae2CcopypastaohmiFe1shie7eoxee2

# Sidekiq settings, protected behind http basic auth
# If you don't include sidekiq username/password, this will disable sidekiq admin panel
SIDEKIQ_REDIS_URL=redis://redis:6379/0
SIDEKIQ_USER=sidekiq
SIDEKIQ_PASSWORD=5b197341fc62d9c9bbcopypastabc7a6cbcf07329c9fe52fa55cab98e

# Suggested you use SendGrid here, use an API key as your password
# Generate them here https://app.sendgrid.com/settings/api_keys
SMTP_SERVER=smtp.sendgrid.net
SMTP_PORT=465
SMTP_USER_NAME=apikey
SMTP_PASSWORD=SG.woithuz8Hiefah1aevaeph4tha8yi1ecopypastaitotouliaGoo0eey7te9hiuF9h

# Microsoft SQL Nomination Export into Dave's system
# Only set these to make this integration run, it ties directly into that database
# TDS_USER=admin
# TDS_PASSWORD=jah2Eifaepoo5fiekaiF3ahnah6pah3o
# TDS_HOST=hugo.ji1Jae0cue1.ap-southeast-2.rds.amazonaws.com
# TDS_DATABASE=Hugo2020

# The rest is identical to the example .env in this README.
# Please copy from there.
```

There's also a `staging.env` next to this which is a variation on these settings. Make sure you use different variables
where possible, particularly `DB_NAME` and `REDIS_URL` options so you don't have clobbering data stores.

On your first run you're going to have to load in the database schema load and some seeds. You can do this from the
image itself by running up an interactive shell and using the rake commands available to that environment. Our database
seeds are stored in `db/seeds` and correspond to runnable rake commands.

Here's the basic recipe to load up a minimal conzealand production:

```
# Run an interactive shell
docker run --env-file=production.env registry.gitlab.com/worldcon/2020-wellington:latest /bin/sh

# Create the database and load the schema
bundle exec rake db:create db:structure:load

# Seed your database
bundle exec rake db:seed:conzealand:production
```

# Production Maintenance and Upgrades

If you're using the docker images, the Docker entry point uses `script/docker_entry.sh` which runs unapplied patches
with `rake db:migrate`. The schema will naturally change over time, for more information about migrations please see
the [Rails Migration](https://guides.rubyonrails.org/active_record_migrations.html) docs.

The docker registry pumps out new images all the time. Here's a make file we're using to run updates on production:

`Makefile`
```make
default: update restart clean logs

ISO_DATE := $(shell date --iso-8601)

update:
	docker-compose pull

restart: stop
	docker-compose rm -f
	docker-compose up -d

logs:
	docker-compose logs -f

stop:
	docker-compose stop

clean:
	docker system prune -a -f

dump:
	# Requires a ~/.pgpass with 0600 based on https://www.postgresql.org/docs/9.1/libpq-pgpass.html to run
	# Settings taken from https://console.aws.amazon.com/rds/home
	pg_dump -U postgres -h mydatabasepasta.lecopypastah.ap-southeast-2.rds.amazonaws.com worldcon_production > production-$(ISO_DATE).sql
```

Note, the configuration above prefixes with. If you use spaces, it'll spray your terminal with errors.

Here's how you'd run your maintenance tasks

```bash
# Pull down the latest images, kick over the services and remove unused containers
make update restart clean

# Dump production SQL for offsite backup
make dump

# Watch production logs
make logs
```

# Configuring pricing

Pricing is handled through Membership records. Creating new records creates new memberships on the shop so long as
they're "active" at the current time. This is managed by setting `active_from` and `active_to` fields.

For instance, to create an Adult membership that varies in price over time, do this by running the following code:

```ruby
# Note, dates and prices are examples. Please don't expect these as a reflection on real dates/prices.
announcement = Date.parse("2018-08-25").midday
price_change = (announcement + 6.months).midday
venue_confirmation = Date.parse("2020-04-01").midday
Membership.create!(name: :adult, active_from: announcement, active_to: price_change price: 400_00)
Membership.create!(name: :adult, active_from: price_change, active_to: venue_confirmation price: 450_00)
```

Of course this is a bunch of effort, the real magic is doing this with seed files. To try this out on your local box,
you can always do this by chaining rake commands together. Development is a rif on production but with dummy data we'd
expect to see from our users such as filled out membership forms, or cast votes for Hugo.

Here's a few examples of you might reset your local database for a minimal setup:

```bash
# Chicago production, see db/seeds/chicago/production.seeds.rb
bundle exec rake db:drop db:create db:schema:load db:seed:chicago:production

# Chicago development, see db/seeds/chicago/development.seeds.rb
bundle exec rake db:drop db:create db:schema:load db:seed:chicago:development

# CoNZealand production, see db/seeds/conzealand/production.seeds.rb
bundle exec rake db:drop db:create db:schema:load db:seed:conzealand:production

# CoNZealand development, see db/seeds/conzealand/development.seeds.rb
bundle exec rake db:drop db:create db:schema:load db:seed:conzealand:development
```

# License

This project is open source based on the Apache 2 Licence. You can read the terms of this in the [License](LICENSE)
file distributed with this project.

- Copyright 2019 AJ Esler
- Copyright 2020 Chris Rose
- Copyright 2019 James Polley
- Copyright 2019 Jen Zajac (jenofdoom)
- Copyright 2019 Steven C Hartley
- Copyright 2020 Matthew B. Gray

We are so grateful to all our contributors for helping us make this project great.
