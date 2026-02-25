#!/bin/bash
set -e

if [ -n "${DOCKER_LOGIN}" ] && [ -n "${DOCKER_PASSWORD}" ] && [ -n "${DOCKER_REGISTRY_URL}" ]; then
    if ! docker login -u "${DOCKER_LOGIN}" -p "${DOCKER_PASSWORD}" "${DOCKER_REGISTRY_URL}"; then
        echo "Docker login failed"
        exit 1
    fi
else
    echo "Skipping Docker login due to missing credentials"
fi

if [ $DOCKER_SYSTEM_PRUNE = 'true' ] ; then
    docker system prune -af
fi

last_arg='.'
if [ $NO_CACHE = 'true' ] ; then
    last_arg='--no-cache .'
fi

docker build \
	--pull \
    $no_cache_arg \
	--build-arg DOCKER_REGISTRY_URL=library \
    --build-arg BASE_IMAGE=ubuntu \
    --build-arg BASE_TAG=20.04 \
    --build-arg ONESCRIPT_PACKAGES="yard" \
    -t ${DOCKER_REGISTRY_URL:+"$DOCKER_REGISTRY_URL/"}oscript-downloader:latest \
	-f oscript/Dockerfile \
    $last_arg

docker build \
    --build-arg ONEC_USERNAME=$ONEC_USERNAME \
    --build-arg ONEC_PASSWORD=$ONEC_PASSWORD \
    --build-arg ONEC_VERSION=$ONEC_VERSION \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg BASE_IMAGE=oscript-downloader \
    --build-arg BASE_TAG=latest \
    -t ${DOCKER_REGISTRY_URL:+"$DOCKER_REGISTRY_URL/"}onec-client:$ONEC_VERSION \
    -f client/Dockerfile \
    $last_arg

if [[ -n "$DOCKER_REGISTRY_URL" ]]; then
  docker push $DOCKER_REGISTRY_URL/onec-client:$ONEC_VERSION
else
  echo "DOCKER_REGISTRY_URL not set, skipping docker push."
fi

docker build \
    --build-arg ONEC_VERSION=$ONEC_VERSION \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    -t ${DOCKER_REGISTRY_URL:+"$DOCKER_REGISTRY_URL/"}onec-client-vnc:$ONEC_VERSION \
    -f client-vnc/Dockerfile \
    $last_arg

if [[ -n "$DOCKER_REGISTRY_URL" ]]; then
  docker push $DOCKER_REGISTRY_URL/onec-client-vnc:$ONEC_VERSION
else
  echo "DOCKER_REGISTRY_URL not set, skipping docker push."
fi

docker build \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg BASE_IMAGE=onec-client-vnc \
    --build-arg BASE_TAG=$ONEC_VERSION \
    --build-arg OVM_VERSION="v1.6.2" \
    --build-arg ONESCRIPT_VERSION="1.9.3" \
    --build-arg ONESCRIPT_PACKAGES="add@SNAPSHOT gitsync vanessa-runner irac stebi edt-ripper" \
    -t ${DOCKER_REGISTRY_URL:+"$DOCKER_REGISTRY_URL/"}onec-client-vnc-oscript:$ONEC_VERSION \
    -f oscript/Dockerfile \
    $last_arg

docker build \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg BASE_IMAGE=onec-client-vnc-oscript \
    --build-arg BASE_TAG=$ONEC_VERSION \
    -t ${DOCKER_REGISTRY_URL:+"$DOCKER_REGISTRY_URL/"}onec-client-vnc-oscript-jdk:$ONEC_VERSION \
    -f jdk/Dockerfile \
    $last_arg

docker build \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg BASE_IMAGE=onec-client-vnc-oscript-jdk \
    --build-arg BASE_TAG=$ONEC_VERSION \
    -t ${DOCKER_REGISTRY_URL:+"$DOCKER_REGISTRY_URL/"}onec-client-vnc-oscript-jdk-testutils:$ONEC_VERSION \
    -f test-utils/Dockerfile \
    $last_arg

docker build \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg BASE_IMAGE=onec-client-vnc-oscript-jdk-testutils \
    --build-arg BASE_TAG=$ONEC_VERSION \
    -t base-gitlab-agent:$ONEC_VERSION \
    -f gitlab-agent/Dockerfile \
    $last_arg

if [[ -n "$DOCKER_REGISTRY_URL" ]]; then
  docker push $DOCKER_REGISTRY_URL/base-gitlab-agent:$ONEC_VERSION
else
  echo "DOCKER_REGISTRY_URL not set, skipping docker push."
fi
