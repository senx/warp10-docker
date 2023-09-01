#
#   Copyright 2016-2023  SenX S.A.S.
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

ENV WARP10_HOME=/opt/warp10
ENV WARP10_VOLUME=/data
ENV PATH=$PATH:${WARP10_HOME}/bin

ARG WARP10_VERSION=3.0.3
ARG WARP10_URL=https://github.com/senx/warp10-platform/releases/download/${WARP10_VERSION}/warp10-${WARP10_VERSION}.tar.gz
ENV WARP10_VERSION=${WARP10_VERSION}

ARG WARPSTUDIO_VERSION=2.1.4-uberjar
ARG WARPSTUDIO_JAR=warp10-plugin-warpstudio-${WARPSTUDIO_VERSION}.jar
ARG WARPSTUDIO_URL=https://repo1.maven.org/maven2/io/warp10/warp10-plugin-warpstudio/${WARPSTUDIO_VERSION}
ARG WARPSTUDIO_SHA512=2c95d429e472874c3c66b216d423e1feb3a296de4fe2784d9382ff9beedffbcd89464df161a55d3b92a160f541f7b4a7ef6743d92f63dc881cfcdc3b45ed0327
ENV WARPSTUDIO_VERSION=${WARPSTUDIO_VERSION}

ARG HFSTORE_VERSION=2.1.1
ARG HFSTORE_JAR=warp10-ext-hfstore-${HFSTORE_VERSION}.jar
ARG HFSTORE_URL=https://maven.senx.io/repository/senx-public/io/senx/warp10-ext-hfstore/${HFSTORE_VERSION}
ARG HFSTORE_SHA512=a6201a5115b1b7b787a1b345dc620fa5b3cfa5424ce659f5d21c8b19d1b301a5baf4cd3331c0a8d82d33f01c299e0c36bafe136916579ed519e1d0745f66f833
ENV HFSTORE_VERSION=${HFSTORE_VERSION}

ARG FOUNDATIONDB_VERSION=7.1.37
ARG FOUNDATIONDB_URL=https://github.com/apple/foundationdb/releases/download/${FOUNDATIONDB_VERSION}
ARG FDBCLI_PKG=foundationdb-clients_${FOUNDATIONDB_VERSION}-1_amd64.deb
ARG FDBCLI_SHA256=dbabbe59b33129e5ebd30f766f85de5c39373047fffb4d354eb9c124797b4dc0
ARG FDBSERVER_PKG=foundationdb-server_${FOUNDATIONDB_VERSION}-1_amd64.deb
ARG FDBSERVER_SHA256=449f879b839638f709be5ddff7494e015ca8c829d47c4299890d9cacb071e53a

RUN set -eux; \
  apt-get update; \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl \
    dirmngr \
    gnupg \
    gosu \
    unifont \
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
## Install Warp 10
##
  cd /opt; \
  wget -q ${WARP10_URL}; \
  tar xzf warp10-${WARP10_VERSION}.tar.gz; \
  rm warp10-${WARP10_VERSION}.tar.gz; \
  ln -s /opt/warp10-${WARP10_VERSION} ${WARP10_HOME}; \
##
## Install WarpStudio
##
  cd ${WARP10_HOME}/lib; \
  wget -q ${WARPSTUDIO_URL}/${WARPSTUDIO_JAR}; \
  wget -q ${WARPSTUDIO_URL}/${WARPSTUDIO_JAR}.asc; \
  gpg --batch --verify ${WARPSTUDIO_JAR}.asc ${WARPSTUDIO_JAR}; \
  rm ${WARPSTUDIO_JAR}.asc; \
  echo "${WARPSTUDIO_SHA512}  ${WARPSTUDIO_JAR}" | sha512sum -c; \
##
## Install HFStore
##
  wget -q ${HFSTORE_URL}/${HFSTORE_JAR}; \
  # wget -q ${HFSTORE_URL}/${HFSTORE_JAR}.asc; \
  # gpg --batch --verify ${HFSTORE_JAR}.asc ${HFSTORE_JAR}; \
  echo "${HFSTORE_SHA512}  ${HFSTORE_JAR}" | sha512sum -c; \
  unzip ${WARP10_HOME}/lib/warp10-ext-hfstore-${HFSTORE_VERSION}.jar hfstore -d ${WARP10_HOME}/bin; \
  mkdir ${WARP10_HOME}/hfiles; \
##
## Install FoundationDB client and server only on x86_64
##
  target=$(uname -m); \
  if [ "x86_64" = "${target}" ]; then \
    cd /var/tmp; \
    wget -q ${FOUNDATIONDB_URL}/${FDBCLI_PKG}; \
    echo "${FDBCLI_SHA256}  ${FDBCLI_PKG}" | sha256sum -c; \
    wget -q ${FOUNDATIONDB_URL}/${FDBSERVER_PKG}; \
    echo "${FDBSERVER_SHA256}  ${FDBSERVER_PKG}" | sha256sum -c; \
    dpkg -i ${FDBCLI_PKG} ${FDBSERVER_PKG}; \
    rm -f /var/tmp/*.deb; \
  fi; \
##
## Fix permissions
##
  chown -RHh warp10:warp10 "${WARP10_HOME}"; \
  chown warp10:warp10 "${WARP10_HOME}"; \
##
## Clean GPG
##
  gpgconf --kill all; \
  rm -rf "$GNUPGHOME";


# Exposing port for Warp 10, Warp Studio, and HFStore
EXPOSE 8080 8081 4378

WORKDIR ${WARP10_HOME}
VOLUME ${WARP10_VOLUME}

HEALTHCHECK CMD curl --fail http://localhost:8080/api/v0/check || exit 1

COPY --chown=warp10:warp10 ./docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "/opt/warp10/bin/warp10.sh", "start" ]
