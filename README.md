# Worldcon Members Management

Kia ora and welcome to the [Wellington](https://gitlab.com/worldcon/wellington) source code repository. This
site hosts and tracks changes to code for managing Members of the [CoNZealand](https://conzealand.nz/) convention.

What you'll find in this project is a series of compromises that we felt struck a balance with features and
functionality. If you have an interest in making your convention or future conventions better do feel free to reach out
by [raising an issue](https://gitlab.com/worldcon/wellington/issues/new) and we'll be happy to talk it over.

[![pipeline status](https://gitlab.com/worldcon/wellington/badges/master/pipeline.svg)](https://gitlab.com/worldcon/wellington/commits/master)
[![coverage report](https://gitlab.com/worldcon/wellington/badges/master/coverage.svg)](https://gitlab.com/worldcon/wellington/commits/master)

# Changelog and Versioning

All notable changes to this project will be documented in [our changelog](CHANGELOG.md).

We maintain published docker images for this project in our
[container registry](https://gitlab.com/worldcon/wellington/container_registry). These track
* all branches that ran through CI including master
* all tags on the project which follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
* `:latest` tracks master which moves after things have gone through code review and basic testing
* `:stable` tracks latest tags and update after a new tag is pushed

# Contacting Us and Contributing

You can contact us by [raising an issue](https://gitlab.com/worldcon/wellington/issues/new) in our tracker.

If you want it to be private, there's a checkbox that marks the issue as *confidential* which will only be visible to
team members. This is particularly important if you need to disclose a security issue, please let us know in confidence
to respect our member's privacy and rights.

If you'd like to contribute, please read our [Contribution Guidelines](CONTRIBUTING.md).

We've got a [Good First Issue](https://gitlab.com/worldcon/wellington/issues?label_name%5B%5D=Good+First+Issue)
label on issues that we feel are valuable to the project, but also a good size for people just starting out. If you're
keen have a look at this list and leave comments on any you'd like to try.

# Getting Started

This project is a super standard Ruby on Rails application that runs on Postgres
and Redis.

## Note On Local Development

For ease of development, this process describes how to configure your
environment to use a dockerized version of Postgres, Redis, and mailcatcher...
but there's no reason you can't just run those locally if you know what you're
doing. Consult your OS's package manager and docs for that

## Set up your environment

The instructions in this section assume you're on either macOS or Linux. All of
the tools exist for Windows, but the commands will differ somewhat (A PR to
update that would be welcome)

If you run into troubles getting any of this working, ask for help by
[raising an issue](https://gitlab.com/worldcon/wellington/issues/new) and we'll be in touch!

From here onwards, we're assuming you're comfortable running commands in your console. These commands will create and install
files on your machine.

### Install docker for your platform

[docker and docker-compose](https://docs.docker.com/compose/install/)
For Windows 10, Install WSL2 (https://docs.microsoft.com/en-us/windows/wsl/install-win10) and Ubuntu (18.04 LTS) before installing Docker.  Configure Docker to use WSL2 (Windows 10 Home will default to this) 

### Install interpreters and environment

To install and configure the ruby version used by Wellington:

```sh
brew install rbenv
rbenv install 2.7.1
rbenv local 2.7.1
```
Windows 10 (from https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-with-rbenv-on-ubuntu-18-04)
```sh
sudo apt update
sudo apt install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
rbenv install 2.7.1
rbenv local 2.7.1  (or) rbenv global 2.7.1
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
ruby -v (to verify install)
```


Configuration for development should be done using whatever method you use for projects, but [direnv](https://direnv.net/) is probably the best one:

```sh
brew install direnv
```

```sh
sudo apt-get install direnv
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
source ~/.bashrc
```

After that step, follow the instructions for your shell to [hook direnv into
your shell](https://direnv.net/docs/hook.html) or else it won't work

**Note:** if you intend to run the rails process directly in your shell (by
running `rails` commands directly) then `direnv` will be a godsend, as the
config won't otherwise read the `.env` file.

### Install basic developer tools.
1. [gnu make](https://www.gnu.org/software/make/),
2. [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).

### Getting the source

Once you have these, clone this project using the git clone command with the URL you get from the clone button on the
top right of the page.

If you've been following or are planning to follow the [Contribution Guidelines](CONTRIBUTING.md), make sure you use the
clone button on your fork of this project.

The command you run will end up looking something like this:

```sh
git clone git@gitlab.com:worldcon/wellington.git worldcon_members_area
```

This will create a directory named `worldcon_members_area` which you should run all the following commands from.

```sh
cd worldcon_members_area
```

### Setup direnv

Before installing dependencies, set up direnv so that they'll be installed to
project-local directories. Put this in the `.envrc` in the
`worldcon_members_area` directory:

```sh
# provide rbenv aliases in the project
use rbenv

# set up a local ruby GEM_HOME
layout ruby

# for some bonkers reason, GEM_PATH doesn't include the new GEM_HOME
path_add GEM_PATH $GEM_HOME

# webpacker and the JS tools need a node modules setup too
layout node

# this will automatically add `.env` to the working environment. Many
# of the keys in the .env template _must_ be present for the
# application to work
dotenv
```

* **Note 1**: If you choose not to use direnv's `ruby` layout, all of the
  `rails` and `rspec` commands below need to be prefixed with `bundle exec`.
  Direnv sets up local wrappers for you on those, which you will probably find
  a lot easier.*

* **Note 2**: `.env` and `.envrc` fill different roles. `.env` is a simple
  KEY=VALUE file that docker will use to populate docker containers. Anything
  all of your docker containers should know goes in here. `.envrc` is for your
  development environment. It configures  your local `GEM_PATH`, node modules,
  and tools. In addition, the example above sources `.env` so that running
  `rails server` will have the same environment as the docker containers.*

### Install dependencies

Note that some of the gems other libraries already installed.
Run these commands to install your ruby and node dependencies:

```sh
sudo apt-get install libpq-dev
sudo apt-get install freetds-dev
bundle install
rbenv rehash

https://docs.microsoft.com/en-us/windows/nodejs/setup-on-wsl2
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
nvm install --lts
sudo apt install yarn
yarn install
```

### Configuring the local system

You're going to need to setup a `.env` file to run this project. This is just a text file, and will keep your
configuration secrets out of source control. Here's an example to get you started!

```sh
# FQDN of the machine that's running the members area
HOSTNAME=localhost:3000

# Stripe keys for payment
# Generate them here https://dashboard.stripe.com/account/apikeys
STRIPE_PUBLIC_KEY=pk_test_zq022DcopypastatXAVMaOJT
STRIPE_PRIVATE_KEY=sk_test_35SiP3qovcopypastaLguIyY
# Stripe webhook secret
# Use the Stripe CLI and `stripe listen --forward-to localhost:3000/stripe_webhook` to configure this in development.
# For production configuration, go to https://dashboard.stripe.com/webhooks
STRIPE_WEBHOOK_ENDPOINT_SECRET=whsec_HcopypastaS7IH3D779S
# https://stripe.com/docs/currencies
STRIPE_CURRENCY=NZD

# Con specific mailer configuration
MAINTAINER_EMAIL=your.name@conzealand.nz

# Con specific configuration.
MEMBER_SERVICES_EMAIL=registrations@conzealand.nz

# WORLDCON_NUMBER is used to designate a con-specific configuration (the set of available ones can be found in `config/convention_details/*.rb*`)
WORLDCON_NUMBER=worldcon80

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
# Note, min payment should cover whatever you set a Supporting membership to
# Having a successful minimum payment unlocks nomination, voting, and hugo packet download
# If not specified, defaults to $75 and $50
INSTALMENT_MIN_PAYMENT_CENTS=7500
INSTALMENT_PAYMENT_STEP_CENTS=5000

# Postgres default values for the development docker-compose.yml services
DB_HOST=localhost
DB_PORT=35432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=secretcopypasta

# Sidekiq is a background task manager which you can view on /sidekiq
# Setting SIDEKIQ_NO_PASSWORD means you can hit this URL without basicauth
# The Redis URL is configured to use the port in the docker-compose.yml
SIDEKIQ_REDIS_URL=redis://localhost:36379/0
SIDEKIQ_NO_PASSWORD=true
# SIDEKIQ_USER=sidekiq
# SIDEKIQ_PASSWORD=5b197341fc62d9c9bbcopypastabc7a6cbcf07329c9fe52fa55cab98e

# hugo packet only shows in menu if HUGO_PACKET_BUCKET present. To make available, you must
# 1. Get the materials from the Hugo admins
# 2. Put them in an S3 bucket that you control
# 3. Create a user with programatic access that has read only access to this bucket
# 4. Generate AWS keys for that user
# 5. Configure on production / staging / local with the following:
# HUGO_PACKET_BUCKET=FROM_STEP_2
# HUGO_PACKET_PREFIX=FROM_STEP_2
# AWS_REGION=ap-southeast-2
# AWS_ACCESS_KEY_ID=FROM_STEP_4
# AWS_SECRET_ACCESS_KEY=FROM_STEP_4

# Uncomment this if you're CoNZealand and need a virtual worldcon <3
# GLOO_BASE_URL=https://api.thefantasy.network/v1
# GLOO_AUTHORIZATION_HEADER=eix1iesa0Shohw1oowoocei0foox4Phij3Dimoa

# Uncomment to reset database on start up, good for switching branches when patches are present
# NAPALM=true
```

If you're on production, please replace fields with your own values or the application will explode with copy pasta
errors ;-)

## Running the service during development

First, start your support services (redis, postgres, mailcatcher)

```sh
make start-support-daemons
```

You can stop these with `make stop` or reset them (tearing down
the DB) using `make reset`. You'll want to do this in particular if you change
the `WORLDCON_CONTACT` or `WORLDCON_THEME` variables, as both of those can
impact the DB tables created and seeded.

Next, start the actual rails application. In development mode it will run
sidekiq in the same process. In production you'll use the different entry points
and the two services will communicate via Redis.

```sh
rails server
```

Changes you make to your machine will show up inside the application which you can browse from http://localhost:3000

All emails sent from the website will be caught and displayed from http://localhost:1080, including login links and
receipts.

If you want to run up a console so you can get a seeded user with dummy reservations, you can do this with:

```sh
rails console
User.all.sample.email
```

A default support user is created as part of seeds. You should be able to sign in as this user by

1. navigating to http://localhost:3000/supports/sign_in
2. signing in with "support@worldcon.org", password 111111

If you need to install or upgrade dependencies, you can get a shell in your environment to run those commands

```sh
yarn upgrade
bundle update
```

If you want to run tests for the project you can do this by running

```sh
make test
```

This runs a lot of tests, but if you're mostly interested in the spec tests this will work better:

```sh
rspec
```

If you've finished working and want to shut down the servers, run

```sh
make stop
```

Cleaning up and starting your DB over from scratch looks like this:

```sh
make reset
```

Or you can go all the way and remove the docker containers, disks and networks:

```sh
make clean
```

From here you can delete the project files if you're done, or just run `make start-support-daemons` and everything will be built again
from scratch.

# Running in Production

We're taking advantage of Gitlab's CI pipeline to build docker images. You can browse our
[list of images](https://gitlab.com/worldcon/wellington/container_registry)
or just follow the `:latest` tag to get things that have gone through CI and code review.

To see all versions available, check out our [container registry](https://gitlab.com/worldcon/wellington/container_registry).
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
    image: registry.gitlab.com/worldcon/wellington:stable
    restart: always
    volumes:
      - type: tmpfs
        target: /app/tmp

  production_worker:
    entrypoint: "script/docker_sidekiq_entry.sh"
    image: registry.gitlab.com/worldcon/wellington:stable
    env_file:
      production.env
    restart: always
    volumes:
      - type: tmpfs
        target: /app/tmp

  staging_web:
    env_file:
      staging.env
    image: registry.gitlab.com/worldcon/wellington:latest
    restart: always
    volumes:
      - type: tmpfs
        target: /app/tmp

  staging_worker:
    entrypoint: "script/docker_sidekiq_entry.sh"
    image: registry.gitlab.com/worldcon/wellington:latest
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
docker run --env-file=production.env registry.gitlab.com/worldcon/wellington:latest /bin/sh

# Create the database and load the schema
bundle exec rake db:create db:structure:load

# Seed your database
bundle exec rake db:seed:conzealand:production
```

# Tailoring to your Con

Our objective is to create a theme for Atlantis 2100, and set the theme and contact by modifying our .env with

```bash
WORLDCON_CONTACT=atlantis
WORLDCON_THEME=atlantis
```

To create a theme for your con, you'll need to:

1. Copy over layout, styles and app files from another con to get you started
   ```bash
   cp app/views/layouts/{conzealand,atlantis}.html.erb
   cp app/javascript/packs/{conzealand,atlantis}-app.js
   cp app/javascript/packs/{conzealand,atlantis}-styles.scss
   ```
2. Copy your favicon into app/javascript/packs/atlantis-favicon.ico
3. Modify app/views/layouts/atlantis.html.erb, change:
   * stylesheet_pack_tag to point at atlantis-app
   * javascript_pack_tag to point at atlantis-styles
   * favicon's resolve_path_to_image should point at media/packs/atlantis-favicon.ico
4. Open `app/lib/theme_concern.rb` and change `#theme_contact_form` to include a case for atlantis
5. Set `WORLDCON_CONTACT=atlantis` in your .env
6. Commit your work
7. Taylor styles.scss and layout.html.erb to suit your con

To create a model for your member contact form, you'll need to:

1. Create a database migration for your tables
   ```bash
   make bash
   bundle exec rails generate model AtlantisContact
   ```
2. Modify the `db/migrate/*_create_atlantis_contacts.rb` file, adding fields you need for your members.
   If you get stuck, use the `db/migrate/20191209052126_create_dc_contact.rb` migration and look up
   the guide on [Active Record Migrations](https://guides.rubyonrails.org/active_record_migrations.html)
   from guides.rubyonrails.org.
3. Update
   * `app/models/atlantis_contact.rb` with constraints-- look at other \_contact models for reference
   * `spec/factories/atlantis_contacts.rb` with defaults-- look at other factories in this directory for examples
   * `spec/models/atlantis_contact_spec.rb` with tests if you've got logic in your model
4. Open `./app/lib/theme_concern.rb` and modify `#theme_contact_param` with `:atlantis_contact`
5. Copy over another con's form to get you started
   ```bash
   make bash
   cp app/views/reservations/_{conzealand,atlantis}_contact_form.html.erb
   ```
6. Modify fields in `app/views/reservations/_atlantis_contact_form.html.erb` to match your contact model.
   For reference, you can use the [Form Helpers guide](https://guides.rubyonrails.org/form_helpers.html)
   from guides.rubyonrails.org.
7. Set `WORLDCON_CONTACT=atlantis` in your .env
8. Run migrations with `bundle exec db:migrate` and commit all your work.

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
- Copyright 2020 Steven Ensslen
- Copyright 2020 Victoria Garcia
- Copyright 2021 Fred Bauer

We are so grateful to all our contributors for helping us make this project great.
