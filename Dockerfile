FROM debian:wheezy

# oracle JDK 8
RUN \
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list && \
  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list && \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
  apt-get update

RUN \
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  apt-get install -y oracle-java8-installer &&\
  apt-get clean

RUN echo "JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> /etc/environment

# Updating
RUN apt-get update && apt-get install -y bash bash-builtins bash-completion curl ca-certificates wget python && apt-get clean
# install domes tools
RUN apt-get update && apt-get install -y aptitude emacs23-nox net-tools procps psmisc htop && apt-get clean

ENV WARP10_VERSION=1.2.6
ENV WARP10_URL=https://bintray.com/artifact/download/cityzendata/generic/io/warp10/warp10/$WARP10_VERSION

RUN mkdir -p /opt

# Getting warp10
RUN cd /opt \
  && wget $WARP10_URL/warp10-$WARP10_VERSION.tar.gz \
  && tar xzf warp10-$WARP10_VERSION.tar.gz \
  && rm warp10-$WARP10_VERSION.tar.gz \
  && ln -s  /opt/warp10-$WARP10_VERSION /opt/warp10

ENV SENSISION_VERSION=1.0.12
ENV SENSISION_URL=https://dl.bintray.com/cityzendata/generic/io/warp10/sensision-service/$SENSISION_VERSION
# FOR local docker build (dev)
# ENV SENSISION_URL = http://{local_ip}:{localport}

# Getting Sensision
RUN cd /opt \
    && wget $SENSISION_URL/sensision-service-$SENSISION_VERSION.tar.gz \
    && tar xzf sensision-service-$SENSISION_VERSION.tar.gz \
    && rm sensision-service-$SENSISION_VERSION.tar.gz \
    && ln -s  /opt/sensision-$SENSISION_VERSION /opt/sensision

# Deleting build-dependencies
RUN apt-get autoremove && apt-get clean

ENV JAVA_HOME=/usr \
  WARP10_HOME=/opt/warp10-${WARP10_VERSION} SENSISION_HOME=/opt/sensision-${SENSISION_VERSION} \
  WARP10_VOLUME=/data MAX_LONG=3153600000000 \
  WARP10_DATA_DIR=/data/warp10 \
  SENSISION_DATA_DIR=/data/sensision
  
ENV WARP10_JAR=${WARP10_HOME}/bin/warp10-${WARP10_VERSION}.jar \
  WARP10_CONF=${WARP10_HOME}/etc/conf-standalone.conf

# REPLACE hard link in configuration template with symbolic link
RUN sed -i 's/^standalone\.home.*/standalone\.home = \/opt\/warp10/' ${WARP10_HOME}/templates/conf-standalone.template
RUN sed -i 's/^sensision\.home.*/sensision\.home = \/opt\/sensision/' ${SENSISION_HOME}/templates/sensision.template
RUN sed -i 's/^sensision\.scriptrunner\.root.*/sensision\.scriptrunner\.root= \/opt\/sensision\/scripts/' ${SENSISION_HOME}/templates/sensision.template

# REPLACE hard link in log4j.properties with symbolic link
RUN sed -i "s/\/opt\/warp10-${WARP10_VERSION}/\/opt\/warp10/" ${WARP10_HOME}/etc/log4j.properties

COPY warp10.start.sh ${WARP10_HOME}/bin/warp10.start.sh
COPY worf.sh ${WARP10_HOME}/bin/worf.sh
COPY setup.sh ${WARP10_HOME}/bin/setup.sh
RUN chmod +x ${WARP10_HOME}/bin/*.sh

ENV PATH=$PATH:${WARP10_HOME}/bin

VOLUME ${WARP10_VOLUME}

# Exposing port 8080 and 8081
EXPOSE 8080 8081

RUN java -version
RUN python --version

CMD ${WARP10_HOME}/bin/warp10.start.sh
