#
#   Copyright 2018  SenX S.A.S.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

FROM openjdk:8-jre-alpine

LABEL author="SenX S.A.S."
LABEL maintainer="contact@senx.io"


# Installing utils need by Warp 10 and build-dependencies
RUN apk --no-cache add bash curl python fontconfig unifont \
  && apk --no-cache add --virtual=build-dependencies ca-certificates wget

ENV JAVA_HOME=/usr \
  WARP10_VOLUME=/data \
  WARP10_HOME=/opt/warp10 \
  WARP10_DATA_DIR=/data/warp10 \
  SENSISION_HOME=/opt/sensision \
  SENSISION_DATA_DIR=/data/sensision

ARG WARP10_VERSION=2.0.3
ARG WARP10_URL=https://dl.bintray.com/senx/generic/io/warp10/warp10/${WARP10_VERSION}

# Getting Warp 10
RUN mkdir -p /opt \
  && cd /opt \
  && wget -nv ${WARP10_URL}/warp10-${WARP10_VERSION}.tar.gz \
  && tar xzf warp10-${WARP10_VERSION}.tar.gz \
  && rm warp10-${WARP10_VERSION}.tar.gz \
  && ln -s /opt/warp10-${WARP10_VERSION} ${WARP10_HOME}

ARG SENSISION_VERSION=1.0.17
ARG SENSISION_URL=https://dl.bintray.com/senx/generic/io/warp10/sensision-service/${SENSISION_VERSION}

# Getting Sensision
RUN cd /opt \
  && wget -nv $SENSISION_URL/sensision-service-${SENSISION_VERSION}.tar.gz \
  && tar xzf sensision-service-${SENSISION_VERSION}.tar.gz \
  && rm sensision-service-${SENSISION_VERSION}.tar.gz \
  && ln -s /opt/sensision-${SENSISION_VERSION} ${SENSISION_HOME}

# Deleting build-dependencies
RUN apk --no-cache del build-dependencies

ENV WARP10_JAR=${WARP10_HOME}/bin/warp10-${WARP10_VERSION}.jar \
  WARP10_CONFIG_DIR=${WARP10_HOME}/etc/conf.d \
  WARP10_CONF=${WARP10_HOME}/etc/conf.d/00_warp10.conf \
  WARP10_MACROS=${WARP10_VOLUME}/custom_macros

COPY warp10.start.sh ${WARP10_HOME}/bin/warp10.start.sh
COPY setup.sh ${WARP10_HOME}/bin/setup.sh

ENV PATH=$PATH:${WARP10_HOME}/bin

VOLUME ${WARP10_VOLUME}
VOLUME ${WARP10_MACROS}


# Exposing port 8080
EXPOSE 8080 8081

CMD ${WARP10_HOME}/bin/warp10.start.sh
