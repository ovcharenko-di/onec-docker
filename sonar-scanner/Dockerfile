ARG DOCKER_REGISTRY_URL
ARG BASE_IMAGE
ARG BASE_TAG

# Версия SonarScanner CLI. Java предоставляется слоем jdk.
# SonarScanner CLI 8.x требует Java 21+, слой jdk собирается с JDK 25 (см. build-sonar-scanner.sh).
ARG SONAR_SCANNER_VERSION=8.1.0.6389

# Стадия загрузки: скачиваем и распаковываем SonarScanner CLI
FROM ${DOCKER_REGISTRY_URL:+"$DOCKER_REGISTRY_URL/"}${BASE_IMAGE}:${BASE_TAG} AS downloader

ARG SONAR_SCANNER_VERSION
USER root

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    unzip \
  && wget -q -O /tmp/sonar-scanner.zip \
    "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip" \
  && unzip -q /tmp/sonar-scanner.zip -d /opt \
  && mv "/opt/sonar-scanner-${SONAR_SCANNER_VERSION}" /opt/sonar-scanner

# Финальный образ: SonarScanner CLI поверх слоя client + jdk (Java из слоя jdk)
FROM ${DOCKER_REGISTRY_URL:+"$DOCKER_REGISTRY_URL/"}${BASE_IMAGE}:${BASE_TAG}

LABEL maintainer="Nikita Fedkin <nixel2007@gmail.com>"

ENV SONAR_SCANNER_HOME=/opt/sonar-scanner

COPY --from=downloader /opt/sonar-scanner ${SONAR_SCANNER_HOME}

ENV PATH="${SONAR_SCANNER_HOME}/bin:${PATH}"

# Java берётся из слоя jdk, поэтому отключаем автоскачивание JRE с сервера
ENV SONAR_SCANNER_SKIP_JRE_PROVISIONING=true

USER usr1cv8

WORKDIR /usr/src

CMD ["sonar-scanner"]
