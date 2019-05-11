#!/usr/bin/env bash

mailcatcher --ip 0.0.0.0

until bundle exec rake dev:bootstrap; do
  sleep 1
  echo
  echo "Retrying bootstrap..."
  echo
done

bundle exec rails server
