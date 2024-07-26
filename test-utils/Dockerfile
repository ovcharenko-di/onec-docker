ARG DOCKER_REGISTRY_URL
ARG BASE_IMAGE
ARG BASE_TAG

FROM ${DOCKER_REGISTRY_URL}/${BASE_IMAGE}:${BASE_TAG}

# Installing additional dependencies
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    cifs-utils \
    inetutils-ping \
    net-tools \
    pandoc \
    scrot \
    xdotool \
  && rm -rf /var/lib/apt/lists/*

RUN echo '#!/bin/bash\n\nscrot "${@:2}"' | tee /usr/local/bin/nircmd \
  && chmod +x /usr/local/bin/nircmd \
  && rm -rf /etc/services.d/onec 2> /dev/null
