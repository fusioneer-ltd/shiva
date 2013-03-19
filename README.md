# Shiva

Rails and ActiveRecord aren't really meant to deal with several database at a time just out of the box.

Shiva extends the rake tasks (like migrate of schema:dump) to work with several databases.

This way you have a folder in db/migrate for each database, a separate schema.rb for each, etc.

## Installation

Add this line to your application's Gemfile:

    gem 'shiva'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shiva

## Usage

### Configuration

You will need to configure Shiva to explain the databases it is supposed to handle

```ruby
Shiva.configure do
  database Databases::Archive # The name will be guessed from the class_name, archive here
  database Databases::Legacy, :old_db # Explicitly define the name
```

### File hierarchy

Now your migrations for Databases::Archive are defined in ```db/migrate/archive``` and those for Databases::Legacy in ```db/migrate/old_db```.

You will also have several schema in ```db/schema```, in our exemple two names ```db/schema/archive_schema.rb``` and one named ```db/schema/old_db_archive.rb```.

### Using rake

To run the migrations for all you databases just run
```rake shiva:migrate````

If you want to run the migrations for a specific database use
```rake shiva:migrate[archive]```

To dump the schema you can use the same principle
```
rake shiva:dump
rake shiva:dump[old_db]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Include tests (we are using rspec)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
