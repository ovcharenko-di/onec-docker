ARG DOCKER_USERNAME=library
ARG BASE_IMAGE=edt
ARG BASE_TAG=2021.3
ARG EDT_PLUGINS=/opt/1C/1CE/components/1c-edt-${BASE_TAG}*-x86_64/plugins

FROM ${DOCKER_USERNAME}/${BASE_IMAGE}:${BASE_TAG} AS base

FROM adoptopenjdk:14-hotspot
LABEL maintainer="Dima Ovcharenko <d.ovcharenko90@gmail.com>, Korus Consulting LLC"

COPY --from=base ${EDT_PLUGINS}/com._1c.g5.v8.dt.debug.core_*.jar ${EDT_PLUGINS}/com._1c.g5.v8.dt.debug.model_*.jar /opt/1C/1CE/

ADD https://github.com/1c-syntax/Coverage41C/releases/download/v2.7.2/Coverage41C-2.7.2.tar /opt/

RUN tar xzf /opt/Coverage41C-2.7.2.tar -C / \
  && rm -rf /opt/Coverage41C-2.7.2.tar

ENV EDT_LOCATION="/opt/1C/1CE/"
ENV PATH="/opt/Coverage41C-2.7.2/bin:$PATH"