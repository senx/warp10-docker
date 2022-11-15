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

##
## Use focal image because there is a segfault with jammy on our build platform
##   => qemu: uncaught target signal 11 (Segmentation fault) - core dumped
##
FROM eclipse-temurin:8-jre-focal

LABEL author="SenX S.A.S."
LABEL maintainer="contact@senx.io"

ENV WARP10_VOLUME=/data \
  WARP10_HOME=/opt/warp10 \
  WARP10_DATA_DIR=/data/warp10

ARG WARP10_VERSION=2.11.1
ARG WARP10_URL=https://github.com/senx/warp10-platform/releases/download/${WARP10_VERSION}/warp10-${WARP10_VERSION}.tar.gz
ENV WARP10_VERSION=${WARP10_VERSION}

ARG WARPSTUDIO_VERSION=2.0.9-uberjar
ARG WARPSTUDIO_CONFIG=${WARP10_HOME}/etc/conf.d/99-io.warp10-warp10-plugin-warpstudio.conf
ARG WARPSTUDIO_JAR=warp10-plugin-warpstudio-${WARPSTUDIO_VERSION}.jar
ARG WARPSTUDIO_URL=https://repo1.maven.org/maven2/io/warp10/warp10-plugin-warpstudio/${WARPSTUDIO_VERSION}
ARG WARPSTUDIO_SHA512=c71e0863af358178f4b61a302f64ccec3ab375df97cd6cb905b413c7722a467198dac514a765d74568049b2d7e5ffcd860d6900ca7dd07e902ab40a61a152acf


ARG HFSTORE_VERSION=2.0.0
ARG HFSTORE_CONFIG=${WARP10_HOME}/etc/conf.d/99-io.senx-warp10-ext-hfstore.conf
ARG HFSTORE_JAR=warp10-ext-hfstore-${HFSTORE_VERSION}.jar
ARG HFSTORE_URL=https://maven.senx.io/repository/senx-public/io/senx/warp10-ext-hfstore/${HFSTORE_VERSION}
ARG HFSTORE_SHA512=8ae3ec2effd42a3730ed8c9f591fe22039568fe450f89bfdf304504bc4049837f7fcba7f85620aa5cd706f51d573e0f4730e3857b0ba674914ad9e21bad3307b


RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    dirmngr \
    gnupg \
    gosu \
    unzip \
  ; \
  rm -rf /var/lib/apt/lists/*;

RUN set -eux; \
##
## Create warp10 user
##
	groupadd --system --gid=942 warp10; \
	useradd --system --gid warp10 --uid=942 --home-dir=${WARP10_HOME} --shell=/bin/bash warp10; \
##
## Get GPG key
##
  export GNUPGHOME="$(mktemp -d)"; \
  gpg --batch --keyserver keyserver.ubuntu.com --receive-keys 09554E7D23D569F502A90A8615E17B2FBD49DA0A; \
##
## Install Warp 10
##
  cd /opt; \
  wget -q ${WARP10_URL}; \
  tar xzf warp10-${WARP10_VERSION}.tar.gz; \
  rm warp10-${WARP10_VERSION}.tar.gz; \
  ln -s /opt/warp10-${WARP10_VERSION} ${WARP10_HOME}; \
  ${WARP10_HOME}/bin/warp10-standalone.init bootstrap; \
##
## Configure Warp 10
##
  sed -i -e 's|^standalone\.host.*|standalone.host = 0.0.0.0|g' ${WARP10_HOME}/etc/conf.d/00-warp.conf; \
  sed -i -e 's|^#warpscript.extension.token.*|warpscript.extension.token = io.warp10.script.ext.token.TokenWarpScriptExtension|g' ${WARP10_HOME}/etc/conf.d/70--extensions.conf; \
##
## Modify start script to run java process in foreground with exec
##
  sed -i -e 's@\(${JAVACMD} ${JAVA_OPTS} -cp ${WARP10_CP} ${WARP10_CLASS} ${CONFIG_FILES}\).*@exec \1@' ${WARP10_HOME}/bin/warp10-standalone.sh; \
##
## Remove secrets and clean
##
  sed -i -e 's/hex:.*/hex:hhh/g' ${WARP10_HOME}/etc/conf.d/*.conf; \
  rm ${WARP10_HOME}/etc/initial.tokens; \
  rm -rf ${WARP10_HOME}/conf.templates; \
##
## Install WarpStudio
##
  cd ${WARP10_HOME}/lib; \
  wget -q ${WARPSTUDIO_URL}/${WARPSTUDIO_JAR}; \
  wget -q ${WARPSTUDIO_URL}/${WARPSTUDIO_JAR}.asc; \
  gpg --batch --verify ${WARPSTUDIO_JAR}.asc ${WARPSTUDIO_JAR}; \
  rm ${WARPSTUDIO_JAR}.asc; \
  echo "${WARPSTUDIO_SHA512}  ${WARPSTUDIO_JAR}" | sha512sum --strict --check; \
##
## Set configuration for WarpStudio
##
  echo 'warp10.plugin.warpstudio = io.warp10.plugins.warpstudio.WarpStudioPlugin' > ${WARPSTUDIO_CONFIG}; \
  echo 'warpstudio.port = 8081' >> ${WARPSTUDIO_CONFIG}; \
  echo 'warpstudio.host = ${standalone.host}' >> ${WARPSTUDIO_CONFIG}; \
##
## Install HFStore
##
  wget -q ${HFSTORE_URL}/${HFSTORE_JAR}; \
  # wget -q ${HFSTORE_URL}/${HFSTORE_JAR}.asc; \
  # gpg --batch --verify ${HFSTORE_JAR}.asc ${HFSTORE_JAR}; \
  echo "${HFSTORE_SHA512}  ${HFSTORE_JAR}" | sha512sum --strict --check; \
  unzip ${WARP10_HOME}/lib/warp10-ext-hfstore-${HFSTORE_VERSION}.jar hfstore -d ${WARP10_HOME}/bin; \
  unzip ${WARP10_HOME}/lib/warp10-ext-hfstore-${HFSTORE_VERSION}.jar warp10-ext-hfstore.conf; \
  mv warp10-ext-hfstore.conf ${HFSTORE_CONFIG}; \
  mkdir ${WARP10_DATA_DIR}/hfiles; \
##
## Fix permissions
##
  chown -RHh warp10:warp10 ${WARP10_HOME} ${WARP10_VOLUME}; \
##
##  Prepare data directory for first run
##
  mv ${WARP10_HOME}/logs/.firstinit ${WARP10_HOME}; \
  mv ${WARP10_VOLUME} ${WARP10_VOLUME}.bak; \
##
## Clean GPG
##
  gpgconf --kill all; \
  rm -rf "$GNUPGHOME";


ENV PATH=$PATH:${WARP10_HOME}/bin


# Exposing port for Warp 10, Warp Studio, and HFStore
EXPOSE 8080 8081 4378

WORKDIR ${WARP10_HOME}
VOLUME ${WARP10_VOLUME}

HEALTHCHECK CMD curl --fail http://localhost:8080/api/v0/check || exit 1

COPY --chown=warp10:warp10 ./docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "/opt/warp10/bin/warp10-standalone.sh", "start" ]
