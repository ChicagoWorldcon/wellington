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

This project is a super standard Ruby on Rails application that runs on Postgres. There's a really simple
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
MEMBER_SERVICES_EMAIL=registrations@conzealand.nz

# Auth secrets, make sure they're super hard to guess!
JWT_SECRET=838734faa9b935c1f8b68846e37aed9096cc9fb746copypastaf856594409a11b1086535e468edb2e5bbc18482b386b6264ada38703dcdefd94a291ab5a95eb5
DEVISE_SECRET=838734faa9b935c1f8b68846e37aed9096cc9fb746copypastaf856594409a11b1086535e468edb2e5bbc18482b386b6264ada38703dcdefd94a291ab5a95eb5

# Postgres default values
DB_HOST=postgres
POSTGRES_USER=postgres
# POSTGRES_PASSWORD="super secret password"

# Suggested you use SendGrid here, use an API key as your password
# Generate them here https://app.sendgrid.com/settings/api_keys
SMTP_SERVER=smtp.sendgrid.net
SMTP_PORT=465
SMTP_USER_NAME=apikey
SMTP_PASSWORD=SG.woithuz8Hiefah1aevaeph4tha8yi1ecopypastaitotouliaGoo0eey7te9hiuF9h
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

If you want to quickly reset your javascript dependencies and database, you can do this with:

```sh
make reset
```

If you want to clean up everything from this project you can do this with:

```sh
make clean
```

From here you can delete the project files if you're done, or just run `make start` and everything will be built again
from scratch.

# Running in Production

We're taking advantage of Gitlab's CI pipeline to build docker images. You can browse our [list of
images](https://gitlab.com/worldcon/2020-wellington/container_registry) or just follow the `:latest` tag to get things
that have gone through CI and code review.

Make sure you set RAILS_ENV to produciton so you take advantager of production specific speedups. If you're managing
your secrets in a .env like your developer environment, just add this:

```
# Used for URL generation and using compiled assets
RAILS_ENV=production
```

You may end up writing your own `docker-compose.yml` for this, or just wiring it up some other way. Here's how you'd do
it with just raw docker commands:

```sh
# Create database
docker run -d --name="test-database" --hostname "postgres" postgres:latest

# Build tables
docker run --env-file=.env --network "container:test-database" registry.gitlab.com/worldcon/2020-wellington:latest bundle exec rake db:create db:schema:load

# Run rails server, TODO bind ports
docker run --env-file=.env --network "container:test-database" registry.gitlab.com/worldcon/2020-wellington:stable bundle exec rake db:migrate && bundle exec rails server -b 0.0.0.0
```

To see all versions available, check out our [container registry](https://gitlab.com/worldcon/2020-wellington/container_registry).
Git tags move `:stable`, merged work that's passed review moves `:latest`.

For more information or options, check out Docker's [extensive documentation](https://docs.docker.com/).

You'll have to manage HTTPS outside of this using something like [elastic load
balancer](https://aws.amazon.com/elasticloadbalancing/) or [caddy server](https://caddyserver.com/).

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

# License

This project is open source based on the Apache 2 Licence. You can read the terms of this in the [License](LICENSE)
file distributed with this project.

- Copyright 2019 AJ Esler
- Copyright 2019 James Polley
- Copyright 2019 Jen Zajac (jenofdoom)
- Copyright 2019 Matthew B. Gray
- Copyright 2019 Steven C Hartley
- Copyright 2019 Chris Rose

We are so grateful to all our contributors for helping us make this project great.
