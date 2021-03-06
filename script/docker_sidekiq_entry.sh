#!/usr/bin/env sh

# Copyright 2020 Matthew B. Gray
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Wait for postgres opens it's ports to start services
if [[ -z $DB_HOST ]]; then
  DB_HOST="postgres"
fi

if [[ -z $DB_NAME ]]; then
    DB_NAME="worldcon_production"
fi

until psql -Atx "postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$DB_HOST/$DB_NAME" -c 'select current_date'; do
  echo "waiting for postgres..."
  sleep 5
done

# Development setup runs when RAILS_ENV is not set
if [[ -z $RAILS_ENV ]]; then
  bundle install --quiet
  yarn install
fi

# Start sidekiq following default and mailer queues
bundle exec sidekiq -q default -q mailers
