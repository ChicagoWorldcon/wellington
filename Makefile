# Copyright 2018 Matthew B. Gray
# Copyright 2019 James Polley
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

.PHONY: build db rubocop apache rspec test logs clean stop start restart napalm

build:
	docker-compose build

db:
	docker-compose exec -T confzealand /bin/bash ./initialize-db.sh

rubocop:
	docker-compose exec -T confzealand rubocop
apache:
	docker-compose exec -T confzealand /bin/bash -c "bundle exec rake test:branch:copyright"
rspec:
	docker-compose exec -T confzealand /bin/bash -c "bundle exec rspec"
test: rspec rubocop apache apache

logs:
	docker-compose logs -f confzealand

clean: stop
	docker-compose down
	docker-compose rm

stop:
	docker-compose stop

start:
	docker-compose up -d

restart:
	docker-compose restart

napalm: clean start db
