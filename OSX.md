# Setting up Postgres and Ruby in OSX

While there is a version of Ruby that comes bundled with OSX, it turns out that it's not under package management.
Production Ruby will be running on a different system, so being able to choose the version of Ruby we're using is
important for working on this project.

These steps rely on the [Homebrew package manager](https://brew.sh/). Please make sure you have it installed when
following this guide.

To manage rubies we can use `ruby-install` to manage which ones are running:

```sh
brew install chruby
brew install ruby-install
ruby-install ruby 2.5.1
```

To switch rubies based on the `.ruby-version` file checked into the project, add this to your `~/.bash_profile` or
`~/.zshrc`:

```sh
source /usr/local/share/chruby/chruby.sh
source /usr/local/share/chruby/auto.sh
```

To setup a default ruby for yourself when you're not working on this project, create a `.ruby-version` in your home
directory:

```sh
echo 2.5.1 > ~/.ruby-version
```

We use postgres in production. Here's how you can get a copy of postgres running on boot:

```sh
brew install postgres
brew services postgres start
```

To continue to setup this project, please refer to the [README.md](README.md).
