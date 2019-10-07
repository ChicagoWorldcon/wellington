# Copyright 2019 Matthew B. Gray
# Copyright 2019 James Polley
# Copyright 2019 Steven C Hartley
# Copyright 2019 AJ Esler
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
start: daemon logs

# stops application containers
stop:
	docker-compose stop

# stops and removes all docker assets used by this application
clean: stop
	docker-compose down --volumes --rmi all # Stop and remove containers, networks, images, and volumes

# stops and removes assets built for the application, leaves base images intact
reset: stop
	docker-compose down --volumes --rmi local

# tails logs of running application
logs:
	docker-compose logs -f # Tail logs

# opens up a REPL that lets you run code in the project
console:
	docker-compose exec members_area bundle exec rails console

# lets you cd around and have a look at the project
shell:
	docker-compose exec members_area sh

# Alias for people who have old habbits
bash: shell

# Tests your setup, similar to CI
test:
	docker-compose exec members_area bundle exec rspec
	docker-compose exec members_area rubocop
	docker-compose exec members_area bundle exec rake test:branch:copyright
	docker-compose exec members_area bundle update brakeman --quiet
	docker-compose exec members_area bundle exec brakeman --run-all-checks --no-pager
	docker-compose exec members_area bundle audit check --update
	docker-compose exec members_area bundle exec ruby-audit check

# builds, configures and starts application in the background
daemon: stop
	docker-compose build --pull # Build or rebuild services; Attempt to pull a newer version of the image
	docker-compose up -d # Create and start containers
	echo "Webserver starting on http://localhost:3000"
	echo "Mailcatcher starting on http://localhost:1080"
