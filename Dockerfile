FROM lwieske/java-8:jdk-8u172-slim

LABEL author="Cityzen Data"
LABEL maintainer="contact@cityzendata.com"

# Updating apk index
RUN apk update && apk add bash curl python

# Installing build-dependencies
RUN apk add --virtual=build-dependencies ca-certificates wget

ENV JAVA_HOME=/usr \
  WARP10_VOLUME=/data \
  WARP10_HOME=/opt/warp10 \
  WARP10_DATA_DIR=/data/warp10 \
  SENSISION_HOME=/opt/sensision \
  SENSISION_DATA_DIR=/data/sensision

ARG WARP10_VERSION=1.2.22
ARG WARP10_URL=https://bintray.com/artifact/download/cityzendata/generic/io/warp10/warp10/${WARP10_VERSION}

# Getting Warp 10
RUN mkdir /opt \
  && cd /opt \
  && wget -nv ${WARP10_URL}/warp10-${WARP10_VERSION}.tar.gz \
  && tar xzf warp10-${WARP10_VERSION}.tar.gz \
  && rm warp10-${WARP10_VERSION}.tar.gz \
  && ln -s /opt/warp10-${WARP10_VERSION} ${WARP10_HOME}

ARG SENSISION_VERSION=1.0.16-rc1
ARG SENSISION_URL=https://dl.bintray.com/cityzendata/generic/io/warp10/sensision-service/${SENSISION_VERSION}

# Getting Sensision
RUN cd /opt \
  && wget -nv $SENSISION_URL/sensision-service-${SENSISION_VERSION}.tar.gz \
  && tar xzf sensision-service-${SENSISION_VERSION}.tar.gz \
  && rm sensision-service-${SENSISION_VERSION}.tar.gz \
  && ln -s /opt/sensision-${SENSISION_VERSION} ${SENSISION_HOME}

# Deleting build-dependencies
RUN apk del build-dependencies

ENV WARP10_JAR=${WARP10_HOME}/bin/warp10-${WARP10_VERSION}.jar \
  WARP10_CONF=${WARP10_HOME}/etc/conf-standalone.conf \
  WARP10_MACROS=${WARP10_VOLUME}/custom_macros

COPY warp10.start.sh ${WARP10_HOME}/bin/warp10.start.sh
COPY setup.sh ${WARP10_HOME}/bin/setup.sh

# Replace default snapshot.sh
RUN mv ${WARP10_HOME}/bin/snapshot.sh ${WARP10_HOME}/bin/snapshot.sh.ORIG
COPY snapshot.sh ${WARP10_HOME}/bin/snapshot.sh

RUN chmod +x ${WARP10_HOME}/bin/*.sh

ENV PATH=$PATH:${WARP10_HOME}/bin

VOLUME ${WARP10_VOLUME}
VOLUME ${WARP10_MACROS}


# Exposing port 8080
EXPOSE 8080 8081

CMD ${WARP10_HOME}/bin/warp10.start.sh
