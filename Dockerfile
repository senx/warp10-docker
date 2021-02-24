#
#   Copyright 2016-2021  SenX S.A.S.
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
RUN apk --no-cache add bash curl fontconfig unifont \
  && apk --no-cache add --virtual=build-dependencies ca-certificates wget

ENV WARP10_VOLUME=/data \
  WARP10_HOME=/opt/warp10 \
  WARP10_DATA_DIR=/data/warp10 \
  SENSISION_HOME=/opt/sensision \
  SENSISION_DATA_DIR=/data/sensision

ARG WARP10_VERSION=2.7.4
ARG WARP10_URL=https://dl.bintray.com/senx/generic/io/warp10/warp10/${WARP10_VERSION}
ENV WARP10_VERSION=${WARP10_VERSION}

ARG WARPSTUDIO_VERSION=1.0.42
ARG WARPSTUDIO_URL=https://dl.bintray.com/senx/maven/io/warp10/warp10-plugin-warpstudio/${WARPSTUDIO_VERSION}
ENV WARPSTUDIO_VERSION=${WARPSTUDIO_VERSION}

# Getting Warp 10
RUN mkdir -p /opt \
  && cd /opt \
  && wget -q ${WARP10_URL}/warp10-${WARP10_VERSION}.tar.gz \
  && tar xzf warp10-${WARP10_VERSION}.tar.gz \
  && rm warp10-${WARP10_VERSION}.tar.gz \
  && ln -s /opt/warp10-${WARP10_VERSION} ${WARP10_HOME} \
  && adduser -D -s -H -h ${WARP10_HOME} -s /bin/bash warp10 \
  && chown -h warp10:warp10 ${WARP10_HOME} \
  && wget -q -P ${WARP10_HOME}/lib ${WARPSTUDIO_URL}/warp10-plugin-warpstudio-${WARPSTUDIO_VERSION}.jar

ARG SENSISION_VERSION=1.0.23
ARG SENSISION_URL=https://dl.bintray.com/senx/generic/io/warp10/sensision-service/${SENSISION_VERSION}
ENV SENSISION_VERSION=${SENSISION_VERSION}

# Getting Sensision
RUN cd /opt \
  && wget -q $SENSISION_URL/sensision-service-${SENSISION_VERSION}.tar.gz \
  && tar xzf sensision-service-${SENSISION_VERSION}.tar.gz \
  && rm sensision-service-${SENSISION_VERSION}.tar.gz \
  && ln -s /opt/sensision-${SENSISION_VERSION} ${SENSISION_HOME} \
  && adduser -D -s -H -h ${SENSISION_HOME} -s /bin/bash sensision \
  && addgroup sensision warp10 \
  && chown -h sensision:sensision ${SENSISION_HOME}

# Deleting build-dependencies
RUN apk --no-cache del build-dependencies

ENV WARP10_JAR=${WARP10_HOME}/bin/warp10-${WARP10_VERSION}.jar \
  WARP10_CONFIG_DIR=${WARP10_HOME}/etc/conf.d \
  WARP10_MACROS=${WARP10_VOLUME}/custom_macros

COPY warp10.start.sh ${WARP10_HOME}/bin/warp10.start.sh
COPY setup.sh ${WARP10_HOME}/bin/setup.sh

ENV PATH=$PATH:${WARP10_HOME}/bin

VOLUME ${WARP10_VOLUME}
# VOLUME ${WARP10_MACROS}

# Exposing port
EXPOSE 8080 8081

CMD ${WARP10_HOME}/bin/warp10.start.sh
