# Shiva

Rails and ActiveRecord are not meant to deal with several databases just out of the box.

Shiva extends Rake tasks (like db:migrate, or schema:dump) to work with several databases.

This way you can set up a separate folder in db/migrate, a separate schema.rb, and so on, for each database.

## Installation

Add this line to your application's Gemfile:

    gem 'shiva'

And then execute:

    $ bundle

Or install it yourself with:

    $ gem install shiva

## Usage

### Configuration

You will need to configure Shiva to explain the databases it is supposed to handle.
You absolutely need to use the class name using a string, we had some weird issues using the class directly with RSpec ... no sure why for now.

```ruby
Shiva.configure do
  database 'Databases::Archive' # The name will be guessed from the class_name, here: archive
  database 'Databases::Legacy', :old_db # Explicitly define the name
end
```

### File hierarchy

Now your migrations for Databases::Archive are defined in ```db/migrate/archive``` and those for Databases::Legacy in ```db/migrate/old_db```.

You will also have several schemas in ```db/schema```. In our example these would be ```db/schema/archive_schema.rb``` and ```db/schema/old_db_archive.rb```.

### Using migrations

    rails generate shiva:migration database_name migration_name

This generator descends from ActiveRecord generator, so you can do all fancy stuff you are already used to.

The only thing you need to do is to provide database_name for Shiva migrator, so it knows which database should it use.

### Using rake

To run the migrations for all your databases just run

    rake shiva:migrate

If you want to run the migrations for a specific database use

    rake shiva:migrate[archive]

To dump the schema you can use the same principle

```
rake shiva:dump
rake shiva:dump[old_db]
```

#### Bare list or Rake tasks

All Rake tasks accept one optional argument, which is a database to work on. When no arguments are passed, work is done on all databases defined by Shiva configurator.

```
rake shiva:migrate
rake shiva:rollback
rake shiva:dump
rake shiva:abort_if_pending_migrations
rake shiva:seeds
rake shiva:schema:load
rake shiva:structure:load
```

### Tests [![build status](https://secure.travis-ci.org/fusioneer-ltd/shiva.png)](http://travis-ci.org/fusioneer-ltd/shiva)

#### Test environment

(Needs updates when using different plaforms)

If you're familiar with `.travis.yml`, you can prepare your own test environment just fine by looking at what's done there.

##### jRuby & SQLite

Due to [an issue in 1.2.9](https://github.com/jruby/activerecord-jdbc-adapter/issues/377) we use a head revision of [`activerecord-jdbc-adapter`](https://github.com/jruby/activerecord-jdbc-adapter) (now in 1.3.0DEV version) for testing our gem:

You will need to [download Ant](http://ant.apache.org/bindownload.cgi) to build JDBC adapters. After that add Ant's `bin` folder into your `PATH` envvar.

```sh
git clone git@github.com:jruby/activerecord-jdbc-adapter.git
cd activerecord-jdbc-adapter
bundle install
rake build adapters:build
cd pkg
gem install activerecord-jdbc-adapter-1.3.0.DEV.gem
gem install activerecord-jdbcsqlite3-adapter-1.3.0.DEV.gem
```

## Known issues

### SQLite

Since SQLite does not support alterations on databases, some of our specs fail while using it (namely migration rollback and schema load). We advise you checking out, if you need these features, or to migrate your database to something more reliable than SQLite.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Include tests (we are using rspec)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
