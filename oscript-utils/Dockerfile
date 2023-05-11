ARG DOCKER_USERNAME
FROM ${DOCKER_USERNAME}/oscript:1.0.21
LABEL maintainer="Anton Kvashenkin <anton.jugatsu@gmail.com> (@jugatsu)"

RUN opm install vanessa-runner \
  && opm install packman \
  && opm install gitsync \
  && opm install deployka \
  && opm install add \
  && opm install vanessa-automation
