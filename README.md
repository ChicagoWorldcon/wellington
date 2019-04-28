# Worldcon Members Management

Kia ora and welcome to the [2020-wellington](https://gitlab.com/worldcon/2020-wellington) source code repository. This
site hosts and tracks changes to code for managing Members of the [CoNZealand](https://conzealand.nz/) conference.

What you'll find in this project is a series of compromises that we felt struck a balance with features and
functionality. If you have an interest in making your convention or future conventions better do feel free to reach out
by [raising an issue](https://gitlab.com/worldcon/2020-wellington/issues/new) and we'll be happy to talk it over.

[![pipeline status](https://gitlab.com/worldcon/2020-wellington/badges/master/pipeline.svg)](https://gitlab.com/worldcon/2020-wellington/commits/master)
[![coverage report](https://gitlab.com/worldcon/2020-wellington/badges/master/coverage.svg)](https://gitlab.com/worldcon/2020-wellington/commits/master)

# Contributing and Contacting Us

You can contact us by [raising an issue](https://gitlab.com/worldcon/2020-wellington/issues/new) in our tracker.

If you want it to be private, there's a checkbox that marks the issue as *confidential* which will only be visible to
team members. This is particularly important if you need to disclose a security issue, please let us know in confidence
to respect our member's privacy and rights.

If you'd like to contribute, please read our [Contribution Guidelines](CONTRIBUTING.md).

We've got a [Good First Issue](https://gitlab.com/worldcon/2020-wellington/issues?label_name%5B%5D=Good+First+Issue)
label on issues that we feel are valuable to the project, but also a good size for people just starting out. If you're
keen have a look at this list and leave comments on any you'd like to try.

# Getting Started

This project has been designed to run inside Docker to simplify setup and testing. Follow [these instructions to install Docker and
docker-compose](https://docs.docker.com/compose/install/).

This has been tested on MacOS and Ubuntu. If you run into troubles getting this working on Linux or MacOS, you can ask
for help by [raising an issue](https://gitlab.com/worldcon/2020-wellington/issues/new). If you manage to get other
platforms working, please create a few instructions and [open a pull
request](https://gitlab.com/worldcon/2020-wellington/merge_requests/new).

We will do our best to not rely on niche PostgreSQL features, so PG 9+ should be fine. The default dev environment uses the latest stable v9.

The first time you bring up your environment, you will also need to initialize the database:

```sh
make db
```

We have a suite of tests written for [rspec](http://rspec.info/) which uses all the above dependencies, lets use it to
check everything is working. After starting and initializing the db, Run the tests with:

```sh
make rspec
```

You're going to need to setup a `.env` file to run this project. This keeps your configuration secrets out of source
control and allows you to configure the project.

```sh
# FQDN of the machine that's running the members area
HOSTNAME=members.conzealand.nz

# Stripe keys for payment
# Generate them here https://dashboard.stripe.com/account/apikeys
STRIPE_PUBLIC_KEY=pk_test_zq022DcopypastatXAVMaOJT
STRIPE_PRIVATE_KEY=sk_test_35SiP3qovcopypastaLguIyY

# Used for URL generation and using compiled assets
# Don't do this on your local machine!
RAILS_ENV=production

# Con specific mailer configuration
EMAIL_PAYMENTS=registration@conzealand.nz

# Auth secrets
# Generate them with `bundle exec rails secret`
JWT_SECRET=838734faa9b935c1f8b68846e37aed9096cc9fb746copypastaf856594409a11b1086535e468edb2e5bbc18482b386b6264ada38703dcdefd94a291ab5a95eb5
DEVISE_SECRET=838734faa9b935c1f8b68846e37aed9096cc9fb746copypastaf856594409a11b1086535e468edb2e5bbc18482b386b6264ada38703dcdefd94a291ab5a95eb5

# Suggested you use SendGrid here, use an API key as your password
# Generate them here https://app.sendgrid.com/settings/api_keys
SMTP_SERVER=smtp.sendgrid.net
SMTP_PORT=465
SMTP_USER_NAME=apikey
SMTP_PASSWORD=SG.woithuz8Hiefah1aevaeph4tha8yi1ecopypastaitotouliaGoo0eey7te9hiuF9h

#Postgres default values
DB_HOST=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=example
```

If you're on production, please replace fields with your own values or the application will explode with copy pasta
errors ;-)

Now start your server with

```bash
make start
```

Then navigate to http://localhost:3000

Email is required to log users in because we use login links. We have set up Mailcatcher to capture and serve all out
bound mail in our development environment.

To start mail capture run:

```sh
make mail
```

And navigate to http://localhost:1080 to view it.

# Running in Production

We're taking advantage of Gitlab's CI pipeline to build docker images. You can browse our [list of
images](https://gitlab.com/worldcon/2020-wellington/container_registry) or just follow the `:latest` tag to get things
that have gone through CI and code review.

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

For lots of examples of membership pricing and setup, please read `db/seeds.rb`.

# License

This project is open source based on the Apache 2 Licence. You can read the terms of this in the [License](LICENSE)
file distributed with this project.

- Copyright 2019 AJ Esler
- Copyright 2019 James Polley
- Copyright 2019 Matthew B. Gray
- Copyright 2019 Steven C Hartley

We are so grateful to all our contributors for helping us make this project great.
