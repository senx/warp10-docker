#
#   Copyright 2016-2022  SenX S.A.S.
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

# Installing utils needed by Warp 10
RUN set -eux; \
    apk add --no-cache \
      bash \
      curl \
      fontconfig \
      unifont \
      ca-certificates \
      wget \
    ;

ENV WARP10_VOLUME=/data \
  WARP10_HOME=/opt/warp10 \
  WARP10_DATA_DIR=/data/warp10 \
  SENSISION_HOME=/opt/sensision \
  SENSISION_DATA_DIR=/data/sensision

ARG WARP10_VERSION=2.11.1
ARG WARP10_URL=https://github.com/senx/warp10-platform/releases/download/${WARP10_VERSION}/warp10-${WARP10_VERSION}.tar.gz
ENV WARP10_VERSION=${WARP10_VERSION}

ARG SENSISION_VERSION=1.0.24
ARG SENSISION_URL=https://github.com/senx/sensision/releases/download/${SENSISION_VERSION}/sensision-service-${SENSISION_VERSION}.tar.gz
ENV SENSISION_VERSION=${SENSISION_VERSION}

ARG WARPSTUDIO_VERSION=2.0.6
ARG WARPSTUDIO_URL=https://repo1.maven.org/maven2/io/warp10/warp10-plugin-warpstudio/${WARPSTUDIO_VERSION}/warp10-plugin-warpstudio-${WARPSTUDIO_VERSION}.jar
ENV WARPSTUDIO_VERSION=${WARPSTUDIO_VERSION}

ARG HFSTORE_VERSION=2.0.0
ARG HFSTORE_URL=https://maven.senx.io/repository/senx-public/io/senx/warp10-ext-hfstore/${HFSTORE_VERSION}/warp10-ext-hfstore-${HFSTORE_VERSION}.jar

# Set up Warp 10
RUN set -eux; \
  mkdir -p /opt; \
  cd /opt; \
  wget -q ${WARP10_URL}; \
  tar xzf warp10-${WARP10_VERSION}.tar.gz; \
  rm warp10-${WARP10_VERSION}.tar.gz; \
  ln -s /opt/warp10-${WARP10_VERSION} ${WARP10_HOME}; \
  wget -q -P ${WARP10_HOME}/lib ${WARPSTUDIO_URL}; \
  wget -q -P ${WARP10_HOME}/lib ${HFSTORE_URL}; \
  adduser -D -s -H -h ${WARP10_HOME} -s /bin/bash warp10; \
  chown -h warp10:warp10 ${WARP10_HOME}; \
  chown -RH warp10:warp10 ${WARP10_HOME}



# Getting Sensision
RUN set -eux; \
  cd /opt; \
  wget -q ${SENSISION_URL}; \
  tar xzf sensision-service-${SENSISION_VERSION}.tar.gz; \
  rm sensision-service-${SENSISION_VERSION}.tar.gz; \
  ln -s /opt/sensision-${SENSISION_VERSION} ${SENSISION_HOME}; \
  adduser -D -s -H -h ${SENSISION_HOME} -s /bin/bash sensision; \
  addgroup sensision warp10; \
  chown -h sensision:sensision ${SENSISION_HOME}; \
  chown -RH sensision:sensision ${SENSISION_HOME}

ENV WARP10_JAR=${WARP10_HOME}/bin/warp10-${WARP10_VERSION}.jar \
  WARP10_CONFIG_DIR=${WARP10_HOME}/etc/conf.d \
  WARP10_MACROS=${WARP10_VOLUME}/custom_macros

# Init HFile environment
RUN cd ${WARP10_HOME}/bin \
  && unzip ${WARP10_HOME}/lib/warp10-ext-hfstore-${HFSTORE_VERSION}.jar hfstore \
  && chmod +x hfstore
RUN cd ${WARP10_HOME}/conf.templates/standalone \
  && unzip ${WARP10_HOME}/lib/warp10-ext-hfstore-${HFSTORE_VERSION}.jar warp10-ext-hfstore.conf \
  && mv warp10-ext-hfstore.conf 99-warp10-ext-hfstore.conf.template

COPY warp10.start.sh ${WARP10_HOME}/bin/warp10.start.sh
COPY setup.sh ${WARP10_HOME}/bin/setup.sh

ENV PATH=$PATH:${WARP10_HOME}/bin

VOLUME ${WARP10_VOLUME}

# Exposing port for Warp 10, Warp Studio, and HFStore
EXPOSE 8080 8081 4378

CMD ${WARP10_HOME}/bin/warp10.start.sh
