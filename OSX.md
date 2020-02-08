# Setting up Postgres and Ruby in OSX

While there is a version of Ruby that comes bundled with OSX, it turns out that it's a bit old and that we don't have
many options about versioning it. Production Ruby will be on a specific version, so being able to choose the version of
Ruby we're using is important for working on this project.

These steps rely on the [Homebrew package manager](https://brew.sh/). Please make sure you have it installed when
following this guide.

To manage rubies we can use `rbenv` to manage which ones are running:

```sh
brew install rbenv
rbenv install 2.6.5
```

For rbenv to hook into your `.ruby-version` file, you need to modify your shell configuration. Add this to your
`~/.bash_profile` or `~/.zshrc`:

```sh
if which rbenv > /dev/null; then
  eval "$(rbenv init -)";
  export PATH="~/.rbenv/bin:$PATH"
fi
```

To setup a default for your user, create a `.ruby-version` in your home directory:

```sh
echo 2.6.5 > ~/.ruby-version
```

This will let you run this version of ruby everywhere, not just the project.

We use yarn on nodejs to manage our dependencies. You can get these two executables from brew and npm:

```sh
brew install node
npm install -g yarn
```

We use postgres in production. Here's how you can get a copy of postgres running and starting up on boot:

```sh
brew install postgres
brew services postgres start
```

We're using freetds to integrate with Dave's Hugo system, and this relies on
Microsoft SQL Server. To connect to this, we need freetds

```sh
brew install freetds
```

You still need secrets exported in order to boot your application. A great way to do this would ber to use `direnv` and
put your secrets into a `.envrc` file.

```sh
brew install direnv
```

Now add this to your `.zshrc` or `.bash_profile`

```sh
if which rbenv > /dev/null; then
  eval "$(rbenv init -)";
  export PATH="~/.rbenv/bin:$PATH"
fi
```

Now copy secrets over from the example from the [README.md](README.md) into a `.envrc` in the base of your checkout.
Each entry will have to be prefixed witb the word `export`. For instance, here's how you should set your postgres host:

```sh
export DB_HOST=postgres
export POSTGRES_USER=$USER
```

Continue to skim through [README.md](README.md), you can use that docker stuff for your production deploys if you like.

Reset or create a new database instance with the napalm script:

```sh
bin/rake dev:napalm
```

Now run your rails server with your standard commands:

```sh
bin/rake db:migrate   # Run migrations
bin/rails server      # Run rails server
bin/rails console     # Console to manipulate models, run queries or commands
```

Happy hacking! &lt;3
