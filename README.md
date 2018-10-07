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
bundle exec rake db:create
```

## Linting

Please use `rubocop-github`. It's better to be consistent, and this just seems like a good line in the sand. There are
plenty of nice [text editor integrations](https://rubocop.readthedocs.io/en/latest/integration_with_other_tools/) to
get a quick feedback loop going.

## Running

You're going to need to setup a .env file to run this project. This keeps your configuration secrets out of source
control and allows you to configure the project.

Create a `.env` file with the following contents:

```bash
# Stripe keys
STRIPE_PUBLIC_KEY=pk_test_zq022Drx7npYPVEtXAVMaOJT
STRIPE_PRIVATE_KEY=sk_test_35SiP34s6qovtenwPPLguIyY

# Mailer configuration
REGISTRATION_ADMIN=registration@conzealand.nz
```

Now start your server with

```bash
make start
```

Then navigate to http://localhost:3000
