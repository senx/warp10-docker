FROM lwieske/java-8:jdk-8u66-slim
MAINTAINER Horacio Gonzalez <horacio.gonzalez@gmail.com>

# Updating apk index
RUN apk update && apk add bash curl python

# Installing build-dependencies
RUN apk add --virtual=build-dependencies ca-certificates wget

ENV WARP10_VERSION=1.0.7
# ENV WARP10_URL=https://bintray.com/artifact/download/cityzendata/generic/io/warp10/warp10/$WARP10_VERSION
# FOR local docker build (dev)
ENV WARP10_URL=http://192.168.1.79:8000

# Getting warp10
RUN mkdir /opt \
  && cd /opt \
  && wget $WARP10_URL/warp10-$WARP10_VERSION.gz \
  && tar xzf warp10-$WARP10_VERSION.gz \
  && rm warp10-$WARP10_VERSION.gz \
  && ln -s  /opt/warp10-$WARP10_VERSION /opt/warp10

ENV SENSISION_VERSION=1.0.5
ENV SENSISION_URL=https://dl.bintray.com/cityzendata/generic/io/warp10/sensision-service/$SENSISION_VERSION
# FOR local docker build (dev)
# ENV SENSISION_URL = http://{local_ip}:{localport}

# Getting Sensision
RUN cd /opt \
    && wget $SENSISION_URL/sensision-service-$SENSISION_VERSION.gz \
    && tar xzf sensision-service-$SENSISION_VERSION.gz \
    && rm sensision-service-$SENSISION_VERSION.gz \
    && ln -s  /opt/sensision-$SENSISION_VERSION /opt/sensision

# Deleting build-dependencies
RUN apk del build-dependencies

ENV QUANTUM_VERSION=1.0.12
# Getting quantum
RUN cd /opt \
    # && wget https://github.com/cityzendata/warp10-quantum/archive/$QUANTUM_VERSION.tar.gz -O ./warp10-quantum-$QUANTUM_VERSION.tar.gz \
    && curl -L https://github.com/cityzendata/warp10-quantum/archive/$QUANTUM_VERSION.tar.gz -o ./warp10-quantum-$QUANTUM_VERSION.tar.gz  \
    && tar xzf warp10-quantum-$QUANTUM_VERSION.tar.gz \
    && rm warp10-quantum-$QUANTUM_VERSION.tar.gz \
    && ln -s /opt/warp10-quantum-$QUANTUM_VERSION /opt/quantum


ENV JAVA_HOME=/usr \
  WARP10_HOME=/opt/warp10-${WARP10_VERSION} SENSISION_HOME=/opt/sensision-${SENSISION_VERSION} \
  WARP10_VOLUME=/data MAX_LONG=3153600000000

ENV WARP10_JAR=${WARP10_HOME}/bin/warp10-${WARP10_VERSION}.jar \
  WARP10_CONF=${WARP10_HOME}/etc/conf-standalone.conf

# REPLACE hard link in configuration template with symbolic link
RUN sed -i 's/^standalone\.home.*/standalone\.home = \/opt\/warp10/' ${WARP10_HOME}/templates/conf-standalone.template
RUN sed -i 's/^sensision\.home.*/sensision\.home = \/opt\/sensision\/data/' ${SENSISION_HOME}/templates/sensision.template
RUN sed -i 's/^sensision\.scriptrunner\.root.*/sensision\.scriptrunner\.root= \/opt\/sensision\/scripts/' ${SENSISION_HOME}/templates/sensision.template

# REPLACE hard link in log4j.properties with symbolic link
RUN sed -i "s/\/opt\/warp10-${WARP10_VERSION}/\/opt\/warp10/" ${WARP10_HOME}/etc/log4j.properties

COPY warp10.start.sh ${WARP10_HOME}/bin/warp10.start.sh
COPY worf.sh ${WARP10_HOME}/bin/worf.sh
COPY setup.sh ${WARP10_HOME}/bin/setup.sh
RUN chmod +x ${WARP10_HOME}/bin/*.sh

ENV PATH=$PATH:${WARP10_HOME}/bin

VOLUME ${WARP10_VOLUME}

# Exposing port 8080
EXPOSE 8080 8081

CMD ${WARP10_HOME}/bin/warp10.start.sh
