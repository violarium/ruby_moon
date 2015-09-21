# Ruby Moon

[![Build Status](https://travis-ci.org/violarium/ruby_moon.svg?branch=master)](https://travis-ci.org/violarium/ruby_moon)
[![Code Climate](https://codeclimate.com/github/violarium/ruby_moon/badges/gpa.svg)](https://codeclimate.com/github/violarium/ruby_moon)

## Project description

**Ruby moon** is web service to help women track their "unhappy days" - menstrual cycles.

It's free and opensource, so you can see the source code or deploy your own site if you have enough experience.

## Deploy

### System requirements

To deploy this application your server have to require some settings and packages:

  * **unix-server** (ubuntu is tested choise)
  * **ruby 2.2**, **rubinius** is possible but not tested yet
  * **mongodb 2.6** or higher
  * **nodejs**

You have to install this packages in case you want run the application.

### Project installation

First of all clone this repository to the machine:

    git clone https://github.com/violarium/ruby_moon.git

Go to created folder:

    cd ruby_moon

Install all the dependencies:

    bundle install

Create configuration files from samples:

    cp config/mongoid.sample.yml config/mongoid.yml
    cp config/secrets.sample.yml config/secrets.yml

And fill them with appropriate data.

Build database indexes:

    bundle exec rake db:mongoid:create_indexes

Run the server:

    bundle exec rails s


## Development

In case you want to help me to work with project or want to create your own, you should fork this project, clone new repository to you local machine and do all the things from **deploy section**.

### Additional system requirements

This project use **phantomjs** to run acceptance tests, so, you have to install it from repository (for ubuntu it's availavle) or just download.

### Development cycle

The good practice is create a branch for new feature or fix.

After you are done, run the tests:

    bundle exec rspec

**TIP!** It's really nice if you write tests for new features.

Push the changes to your fork and create new pull request.
