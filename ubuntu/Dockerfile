#
#   Copyright 2016-2024  SenX S.A.S.
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

FROM eclipse-temurin:8-jre

LABEL author="SenX S.A.S."
LABEL maintainer="contact@senx.io"

ARG BUILD_FDB=true
ARG BUILD_WARPSTUDIO=true
ARG BUILD_HFSTORE=true
ARG BUILD_AWS_BUNDLE=false

ENV BUILD_FDB=${BUILD_FDB}
ENV BUILD_WARPSTUDIO=${BUILD_WARPSTUDIO}
ENV BUILD_HFSTORE=${BUILD_HFSTORE}
ENV BUILD_AWS_BUNDLE=${BUILD_AWS_BUNDLE}

ENV WARP10_HOME=/opt/warp10
ENV WARP10_VOLUME=/data
ENV PATH=$PATH:${WARP10_HOME}/bin

ARG WARP10_VERSION=3.4.0
ARG WARP10_URL=https://github.com/senx/warp10-platform/releases/download/${WARP10_VERSION}/warp10-${WARP10_VERSION}.tar.gz
ARG WARP10_SHA512=74190e09ecb1952d0079c2345b4a88ef955d9e6755fcb63ef9646c5fef09bb24dfd7e2653fc6762fc858c1d505b46673d002093045a27f23a7f4c19ab717b6ac
ENV WARP10_VERSION=${WARP10_VERSION}

ARG WARPSTUDIO_VERSION=2.1.9-uberjar
ARG WARPSTUDIO_JAR=warp10-plugin-warpstudio-${WARPSTUDIO_VERSION}.jar
ARG WARPSTUDIO_URL=https://repo1.maven.org/maven2/io/warp10/warp10-plugin-warpstudio/${WARPSTUDIO_VERSION}
ARG WARPSTUDIO_SHA512=0b9ef61257569973ff99cd2dbe4a2b19dc964bb85bafd2a3453600aadb38172bdfd73102a033d0c1e6fb9e1f01e046fcf639fe070b551453a11b7923af9d72e8
ENV WARPSTUDIO_VERSION=${WARPSTUDIO_VERSION}

ARG HFSTORE_VERSION=3.20.0
ARG HFSTORE_JAR=warp10-ext-hfstore-${HFSTORE_VERSION}.jar
ARG HFSTORE_URL=https://maven.senx.io/repository/senx-public/io/senx/warp10-ext-hfstore/${HFSTORE_VERSION}
ARG HFSTORE_SHA512=60a0d49212edd42f1ecaa4cc5ef50c61ac589555d941a87aeb0ece369c47b7239a981ec9c9822542ceb446bf8b9c77a4a4114d04f3c555efb518e848cae3b068
ENV HFSTORE_VERSION=${HFSTORE_VERSION}

ARG FOUNDATIONDB_VERSION=7.1.37
ARG FOUNDATIONDB_URL=https://github.com/apple/foundationdb/releases/download/${FOUNDATIONDB_VERSION}
ARG FDBCLI_PKG=foundationdb-clients_${FOUNDATIONDB_VERSION}-1_amd64.deb
ARG FDBCLI_SHA256=dbabbe59b33129e5ebd30f766f85de5c39373047fffb4d354eb9c124797b4dc0

ARG AWS_BUNDLE_VERSION=1.12.778
ARG AWS_BUNDLE_JAR=aws-java-sdk-bundle-${AWS_BUNDLE_VERSION}.jar
ARG AWS_BUNDLE_URL=https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_BUNDLE_VERSION}
ARG AWS_BUNDLE_SHA1=adda4f21e680fe65675d59fbd6d06615957d1969
ENV AWS_BUNDLE_VERSION=${AWS_BUNDLE_VERSION}

RUN <<EOF
  set -eux
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl \
    dirmngr \
    gnupg \
    gosu \
    unifont \
    unzip
  rm -rf /var/lib/apt/lists/*
EOF

RUN <<EOF
  set -eux

  ##
  ## Create warp10 user
  ##

  groupadd --system --gid=942 warp10
  useradd --system --gid warp10 --uid=942 --home-dir=${WARP10_HOME} --shell=/bin/bash warp10

  ##
  ## Get GPG keys for: SenX, HBS, AWS SDK
  ##

  export GNUPGHOME="$(mktemp -d)"
  gpg --batch --keyserver keyserver.ubuntu.com --receive-keys 09554E7D23D569F502A90A8615E17B2FBD49DA0A 6528656C2E1408C4D0E0EE57941FD9BB07CAB131 FEB9209F2F2F3F4664841E55AC107B386692DADD

  ##
  ## Install Warp 10
  ##

  cd /opt
  wget -q ${WARP10_URL}
  echo "${WARP10_SHA512}  warp10-${WARP10_VERSION}.tar.gz" | sha512sum -c
  tar xzf warp10-${WARP10_VERSION}.tar.gz
  rm warp10-${WARP10_VERSION}.tar.gz
  ln -s /opt/warp10-${WARP10_VERSION} ${WARP10_HOME}

  ##
  ## Install WarpStudio
  ##

  if [ "true" = "${BUILD_WARPSTUDIO}" ]; then
    cd ${WARP10_HOME}/lib
    wget -q ${WARPSTUDIO_URL}/${WARPSTUDIO_JAR}
    wget -q ${WARPSTUDIO_URL}/${WARPSTUDIO_JAR}.asc
    gpg --batch --verify ${WARPSTUDIO_JAR}.asc ${WARPSTUDIO_JAR}
    rm ${WARPSTUDIO_JAR}.asc
    echo "${WARPSTUDIO_SHA512}  ${WARPSTUDIO_JAR}" | sha512sum -c
  fi

  ##
  ## Install HFStore
  ##

  mkdir ${WARP10_HOME}/hfiles
  if [ "true" = "${BUILD_HFSTORE}" ]; then
    cd ${WARP10_HOME}/lib
    wget -q ${HFSTORE_URL}/${HFSTORE_JAR}
    wget -q ${HFSTORE_URL}/${HFSTORE_JAR}.asc
    gpg --batch --verify ${HFSTORE_JAR}.asc ${HFSTORE_JAR}
    echo "${HFSTORE_SHA512}  ${HFSTORE_JAR}" | sha512sum -c
    rm ${HFSTORE_JAR}.asc
    unzip ${WARP10_HOME}/lib/warp10-ext-hfstore-${HFSTORE_VERSION}.jar hfstore -d ${WARP10_HOME}/bin
  fi

  ##
  ## Install FoundationDB client only on x86_64
  ##

  if [ "true" = "${BUILD_FDB}" ]; then
    target=$(uname -m)
    if [ "x86_64" = "${target}" ]; then
      cd /var/tmp
      wget -q ${FOUNDATIONDB_URL}/${FDBCLI_PKG}
      echo "${FDBCLI_SHA256}  ${FDBCLI_PKG}" | sha256sum -c
      dpkg -i ${FDBCLI_PKG}
      rm -f /var/tmp/${FDBCLI_PKG}
    fi
  fi

  ##
  ## Install AWS Java SDK Bundle
  ##

  if [ "true" = "${BUILD_AWS_BUNDLE}" ]; then
    cd ${WARP10_HOME}/lib
    wget -q ${AWS_BUNDLE_URL}/${AWS_BUNDLE_JAR}
    wget -q ${AWS_BUNDLE_URL}/${AWS_BUNDLE_JAR}.asc
    gpg --batch --verify ${AWS_BUNDLE_JAR}.asc ${AWS_BUNDLE_JAR}
    echo "${AWS_BUNDLE_SHA1}  ${AWS_BUNDLE_JAR}" | sha1sum -c
    rm ${AWS_BUNDLE_JAR}.asc
  fi

  ##
  ## Fix permissions
  ##

  chown -RHh warp10:warp10 "${WARP10_HOME}"
  chown warp10:warp10 "${WARP10_HOME}"

  ##
  ## Clean GPG
  ##

  gpgconf --kill all
  rm -rf "$GNUPGHOME"
EOF

# Exposing port for Warp 10, Warp Studio, and HFStore
EXPOSE 8080 8081 4378

WORKDIR ${WARP10_HOME}
VOLUME ${WARP10_VOLUME}

HEALTHCHECK CMD curl --fail http://localhost:8080/api/v0/check || exit 1

COPY --chown=warp10:warp10 ./docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "/opt/warp10/bin/warp10.sh", "start" ]
