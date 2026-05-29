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

for var in ONEC_USERNAME ONEC_PASSWORD ONEC_VERSION; do
    if [ -z "${!var}" ]; then
        echo "Required environment variable $var is not set" >&2
        exit 1
    fi
done

# SonarScanner CLI 8.x требует Java 21+, поэтому слой jdk собираем с JDK 25
SONAR_JDK_VERSION="${SONAR_JDK_VERSION:-25}"

docker build \
    --pull \
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
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg BASE_IMAGE=onec-client \
    --build-arg BASE_TAG=$ONEC_VERSION \
    --build-arg OPENJDK_VERSION=$SONAR_JDK_VERSION \
    -t ${DOCKER_REGISTRY_URL:+"$DOCKER_REGISTRY_URL/"}onec-client-jdk:$ONEC_VERSION \
    -f jdk/Dockerfile \
    $last_arg

if [[ -n "$DOCKER_REGISTRY_URL" ]]; then
  docker push $DOCKER_REGISTRY_URL/onec-client-jdk:$ONEC_VERSION
else
  echo "DOCKER_REGISTRY_URL not set, skipping docker push."
fi

docker build \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg BASE_IMAGE=onec-client-jdk \
    --build-arg BASE_TAG=$ONEC_VERSION \
    -t ${DOCKER_REGISTRY_URL:+"$DOCKER_REGISTRY_URL/"}onec-sonar-scanner:$ONEC_VERSION \
    -f sonar-scanner/Dockerfile \
    $last_arg

if [[ -n "$DOCKER_REGISTRY_URL" ]]; then
  docker push $DOCKER_REGISTRY_URL/onec-sonar-scanner:$ONEC_VERSION
else
  echo "DOCKER_REGISTRY_URL not set, skipping docker push."
fi
