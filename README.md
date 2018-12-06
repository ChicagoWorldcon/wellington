# Worldcon Members Management

Kiora and welcome to the [2020-wellington](https://gitlab.com/worldcon/2020-wellington) source code repository. This
site hosts and tracks changes to code that used for managing Members of the [CoNZealand](https://conzealand.nz/)
conference.

The work itself was inspired by the [Kansa](https://github.com/maailma/kansa) project which was built largely by [Eemeli
Aro](https://github.com/eemeli) for [Worldcon 75](https://www.worldcon.fi/).

What you'll find in this project is a series of compromises that we felt struck a balance with features and
functionality. If you have an interest in making your convention or future conventions better do feel free to reach out
by [raising an issue](https://gitlab.com/worldcon/2020-wellington/issues) and we'll be happy to talk it over.

[![pipeline status](https://gitlab.com/worldcon/2020-wellington/badges/master/pipeline.svg)](https://gitlab.com/worldcon/2020-wellington/commits/master)
[![coverage report](https://gitlab.com/worldcon/2020-wellington/badges/master/coverage.svg)](https://gitlab.com/worldcon/2020-wellington/commits/master)

# Getting Started

This project depends on [Ruby](http://ruby-lang.org/) and [PostgreSQL](https://www.postgresql.org/).

We will do our best to not rely on niche PostgreSQL features, so PG 9+ should be fine.

Ruby versions matter a bit more. This project only maintains against a single version is set in the
[.ruby-version](.ruby-version) file at the base of this repository. When present, this file auto configures ruby
management tools such as [rbenv](https://github.com/rbenv/rbenv#readme) and
[chruby](https://github.com/postmodern/chruby#readme) to figure out which ruby to use and where to find it's installed
gems. You can find out more about all the ways to install ruby from the official [installing
ruby](https://www.ruby-lang.org/en/documentation/installation) page.

If you're running OSX, I've setup a [quickstart guide](OSX.md) to help people setup Ruby and Postgres quickly. If you
run into troubles getting this working on Linux or Windows, you can ask for help by [raising an
issue](https://gitlab.com/worldcon/2020-wellington/issues/new). If you manage to get those platforms working, please
create a few instructions and [open a pull request](https://gitlab.com/worldcon/2020-wellington/merge_requests/new).

Once you've got Ruby and Postgres setup, we can go on to installing project dependencies. We depend on [Ruby
Gems](https://rubygems.org/) and manage these dependencies through [bundler](https://bundler.io/). You can install these
dependencies by running:

```sh
gem install bundler
bundle install
```

We have rake tasks and you can use these to get our development and test databases up and running

```sh
bundle exec rake db:create       # Creates the database
bundle exec rake db:schema:load  # Loads tables from db/schema.rb
bundle exec rake db:seed         # Seeds our developemnt database
```

We have a suite of tests written for [rspec](http://rspec.info/) which uses all the above dependencies, lets use it to
check everything is working. Run the tests with:

```sh
bundle exec rspec
```

If you want to see what this project would look like on the web, you can do this by running a rails server:

```sh
bundle exec rails server
```

Then navigating to http://localhost:3000

# Production Secrets

You're going to need to setup a .env file to run this project. This keeps your configuration secrets out of source
control and allows you to configure the project.

Create a `.env` file with the following contents:

```bash
# Stripe keys
STRIPE_PUBLIC_KEY=pk_test_zq022DcopypastatXAVMaOJT
STRIPE_PRIVATE_KEY=sk_test_35SiP3qovcopypastaLguIyY

# Mailer configuration
EMAIL_PAYMENTS=registration@conzealand.nz

# Suggested you use SendGrid here, use an API key as your password
# Generate them here https://app.sendgrid.com/settings/api_keys
SMTP_SERVER=smtp.sendgrid.net
SMTP_PORT=465
SMTP_USER_NAME=apikey
SMTP_PASSWORD=SG.woithuz8Hiefah1aevaeph4tha8yi1ecopypastaitotouliaGoo0eey7te9hiuF9h
```

Now start your server with

```bash
make start
```

Then navigate to http://localhost:3000

# Configuring pricing

Pricing is handled through Membership records. Creating new records creates new memberships on the shop so long as
they're "active" at the current time. This is managed by setting `active_from` and `active_to` fields.

For instance if I want to create an Adult membership that varies in price over time, I could do this by running the
following code:

```ruby
# Note, dates and prices are examples. Please don't expect these as a reflection on real dates/prices.
announcement = Date.parse("2018-08-25").midday
price_change = (announcement + 6.months).midday
venue_confirmation = Date.parse("2020-04-01").midday
Membership.create!(name: :adult, active_from: announcement, active_to: price_change price: 400_00)
Membership.create!(name: :adult, active_from: price_change, active_to: venue_confirmation price: 450_00)
```

For lots of examples of membership pricing and setup, please read `db/seeds.rb`.

# Contributing

If you'd like to contribute, please read our [Contribution Guidelines](CONTRIBUTING.md).

# License

This project is open source based on the Apache 2 Licence. You can read the terms of this in the [License](LICENSE)
file distributed with this project.
