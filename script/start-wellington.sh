#!/bin/bash
# Why does this need a script? Because we have some weird environment variables set up so that we can use DigitalOcean
# spaces, and I want my local testing to use that too, since it's not 100% the same as S3
#
# Note that this script depends on my `,aws-creds` script, which finds a JSON credential doc in the keychain

set -eu
set -o pipefail

AWS_ACCESS_KEY_ID=$(,aws-creds chicon-digitalocean | jq -r .AccessKeyId)
AWS_SECRET_ACCESS_KEY=$(,aws-creds chicon-digitalocean | jq -r .SecretAccessKey)
AWS_ENDPOINT=https://nyc3.digitaloceanspaces.com
AWS_REGION=$(aws --profile=chicon-spaces configure get region)

export AWS_REGION AWS_SECRET_ACCESS_KEY AWS_ENDPOINT AWS_ACCESS_KEY_ID

exec rails server
