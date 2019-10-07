#!/usr/bin/env sh

# Copyright 2019 Matthew B. Gray
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
until nc -z $DB_HOST 5432; do
  echo "waiting for postgres..."
  sleep 1
done

# Development setup runs when RAILS_ENV is not set
if [[ -z $RAILS_ENV ]]; then
  mailcatcher --ip 0.0.0.0
  bin/rake dev:bootstrap
fi

# Run migrations and start the server, anything that comes in on 3000 is accepted
bin/rake db:migrate
bin/rails server -b 0.0.0.0
