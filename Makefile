# Copyright 2019 James Polley
# Copyright 2019 Steven C Hartley
# Copyright 2019 AJ Esler
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

# starts daemon then tails logs
start-support-daemons: stop
	echo "Mailcatcher starting on http://localhost:1080"
	docker-compose up -d # Create and start containers

start: start-support-daemons
	rails server

# stops application containers
stop:
	docker-compose stop

# stops and removes all docker assets used by this application
clean: stop
	docker-compose down --volumes --rmi all # Stop and remove containers, networks, images, and volumes

# stops and removes assets built for the application, leaves base images intact
reset: stop
	docker-compose down --volumes --rmi local
	docker-compose up -d
	rake dev:bootstrap

# tails logs of running application
logs:
	docker-compose logs -f # Tail logs

# opens up a REPL that lets you run code in the project
console:
	bundle exec rails console

# open a databaes console so you can run SQL queries
# e.g. SELECT * FROM users;
sql:
	postgres psql -U postgres worldcon_development

# Tests only specs introduced on your current branch
test_changes:
	git diff origin/master... --name-only | grep '_spec' | ls | bundle exec rspec

# Tests your setup, similar to CI
test:
	bundle exec rspec
	rubocop
	rake test:branch:copyright
	bundle update brakeman --quiet
	bundle exec brakeman --run-all-checks --no-pager
	bundle audit check --update
	bundle exec ruby-audit check

# builds, configures and starts application in the background using tmux
daemon: start-support-daemon
	docker-compose up -d # Create and start containers
	scripts/start-server-in-tmux.sh
	echo "Webserver starting on http://localhost:3000"
	echo "Mailcatcher starting on http://localhost:1080"


stop-daemon:
	script/stop-server-in-tmux.sh
