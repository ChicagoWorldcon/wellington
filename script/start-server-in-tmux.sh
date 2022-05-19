#!/usr/bin/env bash

# Copyright 2020 Chris Rose
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

if hash tmux 2>/dev/null; then
    if tmux has-session -t wellington; then
        echo 'Tmux already has a wellington session. Run `tmux attach-session -t wellington` to see the logs'
    else

        # getting our weird Spaces creds. We keep these out of .env so that we can interact with AWS AND DO.
        AWS_ACCESS_KEY_ID=$(aws-creds chicon-digitalocean | jq -r .AccessKeyId)
        AWS_SECRET_ACCESS_KEY=$(aws-creds chicon-digitalocean | jq -r .SecretAccessKey)
        AWS_ENDPOINT=https://nyc3.digitaloceanspaces.com
        AWS_REGION=$(aws --profile=chicon-spaces configure get region)

        export AWS_REGION AWS_SECRET_ACCESS_KEY AWS_ENDPOINT AWS_ACCESS_KEY_ID

        tmux new-session -d -s wellington rails server
        tmux split-window -t wellington -v -f 'webpack-dev-server'
        echo 'Rails started in the background. To see logs, run `tmux attach-session -t wellington`'
    fi
else
    echo "tmux must be installed to start the service in the background"
    exit 1
fi
