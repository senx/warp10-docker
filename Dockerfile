FROM lwieske/java-8:jdk-8u66-slim
MAINTAINER Horacio Gonzalez <horacio.gonzalez@gmail.com>

# Updating apk index
RUN apk update && apk add bash curl python

# Installing build-dependencies
RUN apk add --virtual=build-dependencies ca-certificates wget

ENV WARP10_VERSION=1.0.1

# Getting warp10
RUN mkdir /opt \
  && cd /opt \
  && wget https://bintray.com/artifact/download/cityzendata/generic/warp10-$WARP10_VERSION.tar.gz \
  && tar xzf warp10-$WARP10_VERSION.tar.gz \
  && rm warp10-$WARP10_VERSION.tar.gz \
  && ln -s  /opt/warp10-$WARP10_VERSION /opt/warp10

ENV SENSISION_VERSION=1.0.0

# Getting Sensision
RUN cd /opt \
    && wget https://dl.bintray.com/cityzendata/generic/sensision-service-$SENSISION_VERSION.tar.gz \
    && tar xzf sensision-service-$SENSISION_VERSION.tar.gz \
    && rm sensision-service-$SENSISION_VERSION.tar.gz \
    && ln -s  /opt/sensision-$SENSISION_VERSION /opt/sensision

# Deleting build-dependencies
RUN apk del build-dependencies

ENV QUANTUM_VERSION=1.0.0
# Getting quantum
RUN cd /opt \
    && wget https://github.com/cityzendata/warp10-quantum/archive/$QUANTUM_VERSION.tar.gz -O ./warp10-quantum-$QUANTUM_VERSION.tar.gz \
    && tar xzf warp10-quantum-$QUANTUM_VERSION.tar.gz \
    && rm warp10-quantum-$QUANTUM_VERSION.tar.gz \
    && ln -s /opt/warp10-quantum-$QUANTUM_VERSION /opt/quantum


ENV JAVA_HOME=/usr \
  WARP10_HOME=/opt/warp10-${WARP10_VERSION} SENSISION_HOME=/opt/sensision-${SENSISION_VERSION} \
  WARP10_VOLUME=/data MAX_LONG=3153600000000

ENV WARP10_JAR=${WARP10_HOME}/bin/warp10-${WARP10_VERSION}.jar \
  WARP10_CONF=${WARP10_HOME}/etc/conf-standalone.conf


COPY warp10.start.sh ${WARP10_HOME}/bin/warp10.start.sh
COPY worf.sh ${WARP10_HOME}/bin/worf.sh
COPY bashrc /root/.bashrc
RUN chmod +x ${WARP10_HOME}/bin/*.sh

ENV PATH=$PATH:${WARP10_HOME}/bin

VOLUME ${WARP10_VOLUME}

# Exposing port 8080
EXPOSE 8080 8081

CMD ${WARP10_HOME}/bin/warp10.start.sh
