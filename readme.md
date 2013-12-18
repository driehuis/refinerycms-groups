# Refinery CMS Groups
===================

[Refinery CMS](http://refinerycms.com) extension which allows grouping users.

Use case : You want to manage membership for a family. You allow a member of this family to add new users.

## Requirements

Refinery CMS version 2.1.x

## Install

Open up your ``Gemfile`` and add at the bottom this line:

```ruby
gem 'refinerycms-groups', '~> 2.1.0'
```

Now, run ``bundle install``

Next, to install the groups extension run:

    rails generate refinery:groups

Run database migrations:

    rake db:migrate

Finally seed your database and you're done.

    rake db:seed

## Developing & Contributing

The version of Refinery to develop this engine against is defined in the gemspec. To override the version of refinery to develop against, edit the project Gemfile to point to a local path containing a clone of refinerycms.

### Testing

Generate the dummy application to test against

    $ bundle exec rake refinery:testing:dummy_app

Run the test suite with [Guard](https://github.com/guard/guard)

     $ bundle exec guard start

Or just with rake spec

     $ bundle exec rake spec

## More Information

* Check out [Refinery CMS Website](http://refinerycms.com/)

### How to build this extension as a gem

    cd vendor/extensions/groups
    gem build refinerycms-groups.gemspec
    gem install refinerycms-groups.gem

Sign up for a http://rubygems.org/ account and publish the gem
    
    gem push refinerycms-groups.gem
