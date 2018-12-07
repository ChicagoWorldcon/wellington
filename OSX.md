# Setting up Postgres and Ruby in OSX

While there is a version of Ruby that comes bundled with OSX, it turns out that it's a bit old and that we don't have
many options about versioning it. Production Ruby will be on a specific version, so being able to choose the version of
Ruby we're using is important for working on this project.

These steps rely on the [Homebrew package manager](https://brew.sh/). Please make sure you have it installed when
following this guide.

To manage rubies we can use `ruby-install` to manage which ones are running:

```sh
brew install chruby
brew install ruby-install
ruby-install ruby 2.5.1
```

For chruby to hook into your `.ruby-version` file, you need to modify your shell configuration. Add this to your
`~/.bash_profile` or `~/.zshrc`:

```sh
source /usr/local/share/chruby/chruby.sh
source /usr/local/share/chruby/auto.sh
```

To setup a default system ruby for yourself, create a `.ruby-version` in your home directory:

```sh
echo 2.5.1 > ~/.ruby-version
```

We use postgres in production. Here's how you can get a copy of postgres running on boot:

```sh
brew install postgres
brew services postgres start
```

To continue to setup this project, please refer to the [README.md](README.md).
