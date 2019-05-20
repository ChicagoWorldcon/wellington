# Copyright 2019 Matthew B. Gray
# Copyright 2019 James Polley
# Copyright 2019 Steven C Hartley
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

# stops and removes application containers and volumes
clean: stop
	docker-compose rm -f # Remove stopped containers; Don't ask to confirm removal

# tails logs of running application
logs:
	docker-compose logs -f # Tail logs

# opens up a REPL that lets you run code in the project
console:
	docker-compose exec members_area bundle exec rails console

# lets you cd around and have a look at the project
bash:
	docker-compose exec members_area bash

# Tests your setup, similar to CI
test:
	docker-compose exec members_area bundle exec rspec
	docker-compose exec members_area rubocop
	docker-compose exec members_area bundle exec rake test:branch:copyright

# builds, configures and starts application in the background
daemon: stop
	docker pull registry.gitlab.com/worldcon/2020-wellington:latest # Pull prebuilt images
	docker-compose build --pull # Build or rebuild services; Attempt to pull a newer version of the image
	docker-compose up -d # Create and start containers
	echo "Webserver starting on http://localhost:3000"
	echo "Mailcatcher starting on http://localhost:1080"
