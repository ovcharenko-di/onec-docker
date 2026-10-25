#!/usr/bin/env bash
set -eo pipefail

if [ -n "${DOCKER_LOGIN}" ] && [ -n "${DOCKER_PASSWORD}" ] && [ -n "${DOCKER_REGISTRY_URL}" ]; then
    if ! docker login -u "${DOCKER_LOGIN}" -p "${DOCKER_PASSWORD}" "${DOCKER_REGISTRY_URL}"; then
        echo "Docker login failed"
        exit 1
    fi
else
    echo "Skipping Docker login due to missing credentials"
fi

if [ "${DOCKER_SYSTEM_PRUNE}" = 'true' ] ; then
    docker system prune -af
fi

last_arg='.'
if [ "${NO_CACHE}" = 'true' ] ; then
    last_arg='--no-cache .'
fi

edt_version=$EDT_VERSION
edt_escaped="${edt_version// /_}"

./build-edt.sh

docker build \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg BASE_IMAGE=edt \
    --build-arg BASE_TAG=$edt_escaped \
    -t ${DOCKER_REGISTRY_URL:+"$DOCKER_REGISTRY_URL/"}edt-s6:$edt_escaped \
    -f s6-overlay/Dockerfile \
    $last_arg

if [[ -n "$DOCKER_REGISTRY_URL" ]]; then
  docker push $DOCKER_REGISTRY_URL/edt-s6:$edt_escaped
else
  echo "DOCKER_REGISTRY_URL not set, skipping docker push."
fi

docker build \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg BASE_IMAGE=edt-s6 \
    --build-arg BASE_TAG=$edt_escaped \
    -t ${DOCKER_REGISTRY_URL:+"$DOCKER_REGISTRY_URL/"}edt-agent:$edt_escaped \
    -f swarm-jenkins-agent/Dockerfile \
    $last_arg

if [[ -n "$DOCKER_REGISTRY_URL" ]]; then
  docker push $DOCKER_REGISTRY_URL/edt-agent:$edt_escaped
else
  echo "DOCKER_REGISTRY_URL not set, skipping docker push."
fi
