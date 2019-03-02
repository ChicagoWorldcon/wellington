# Copyright 2018 Matthew B. Gray
# Copyright 2019 James Polley
# Copyright 2019 Steven Hartley
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

.PHONY: build db rubocop apache rspec test logs clean stop start restart napalm mail 

build:
	docker-compose build

db:
	docker-compose exec -T members_area /bin/bash -c "bundle exec rake dev:bootstrap"

rubocop:
	docker-compose exec -T members_area rubocop
apache:
	docker-compose exec -T members_area /bin/bash -c "bundle exec rake test:branch:copyright"
rspec:
	docker-compose exec -T members_area /bin/bash -c "bundle exec rspec"
test: rspec rubocop apache apache

logs:
	docker-compose logs -f members_area

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

mail:
	docker-compose exec -T members_area mailcatcher --ip 0.0.0.0
	@echo "To see email, go to the MailCatcher web interface at http://localhost:1080"
	

		
