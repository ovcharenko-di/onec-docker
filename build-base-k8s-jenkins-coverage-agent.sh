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

./build-edt.sh

export PUSH_AGENT='false'
./build-base-k8s-jenkins-agent.sh

docker build \
   --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
   --build-arg BASE_IMAGE=base-jenkins-agent \
   --build-arg BASE_TAG=$ONEC_VERSION \
   --build-arg EDT_VERSION=$EDT_VERSION \
   --build-arg COVERAGE41C_VERSION=$COVERAGE41C_VERSION \
   -t $DOCKER_REGISTRY_URL/base-jenkins-coverage-agent:$ONEC_VERSION \
   -f coverage41C/Dockerfile \
   $last_arg

docker push $DOCKER_REGISTRY_URL/base-jenkins-coverage-agent:$ONEC_VERSION
