# Worldcon Members Management

Holds information about members of worldcon.

## Install Steps

This project depends on Ruby.

One way to get this version of ruby is using [ruby-install](https://github.com/postmodern/ruby-install).

Here's how I'd do this on OSX.
```sh
brew install chruby
brew install ruby-install
ruby-install ruby 2.5.1
```

Add this to your `~/.bash_profile` or `~/.zshrc`
```bash
source /usr/local/share/chruby/chruby.sh
source /usr/local/share/chruby/auto.sh
```

Setup a default ruby for yourself
```bash
2.5.1 >> ~/.ruby-version
```

Install postgresql
```bash
brew install postgres@9.6
brew services postgres@9.6 start
```

Install project dependencies
```bash
gem install bundler
bundle install
```

Setup your developemnt database
```bash
bundle exec rake db:create db:schema:load db:seed
```

## Ruby is being painful! Halp!

Here's something that'll reset things for yah in OSX:

```bash
sudo rm -rf ~/.gem ~/.rubies
ruby-install ruby-2.5.1

# Check installed rubies
cd $conzealand_checkout
ruby -v
> ruby 2.5.1p57 (2018-03-29 revision 63029) [x86_64-darwin18]
which ruby
> /Users/mbgray/.rubies/ruby-2.5.1/bin/ruby
which gem
> /Users/mbgray/.rubies/ruby-2.5.1/bin/gem

# Bundle things
cd $conzealand_checkout
gem install bundler
bundle install

# tests = <3
git checkout origin/8-import-presupporters
bundle exec rspec
> Finished in 1.8 seconds (files took 5.27 seconds to load)
> 105 examples, 0 failures
```

## Linting

Please use `rubocop-github`. It's better to be consistent, and this just seems like a good line in the sand. There are
plenty of nice [text editor integrations](https://rubocop.readthedocs.io/en/latest/integration_with_other_tools/) to
get a quick feedback loop going.

# Running

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

## Condfiguring pricing

Pricing is handled through Membership records. Creating new records creates new membreships on the shop so long as
they're "active".

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
