#!/usr/bin/env bash
set -euo pipefail

if test -f /opt/chicago/etc/wellington/tag.env; then
    . /opt/chicago/etc/wellington/tag.env
fi

export WELLINGTON_DOCKER_TAG=${WELLINGTON_DOCKER_TAG:-staging}

eval $(docker run rlister/ecr-login:latest)

/usr/bin/docker-compose -f /opt/chicago/app/wellington/docker-compose.yml pull
