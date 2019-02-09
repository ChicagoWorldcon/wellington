#!/bin/bash
# Copyright 2019 James Polley

cd /app
bundle exec rake db:create       # Creates the database
bundle exec rake db:schema:load  # Loads tables from db/schema.rb
bundle exec rake db:seed         # Seeds our developemnt database

bundle exec rake dev:generate:users # Generate sample users with purchases
