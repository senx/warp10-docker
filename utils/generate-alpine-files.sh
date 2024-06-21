#!/usr/bin/env sh
#
#   Copyright 2022  SenX S.A.S.
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

set -eu

mkdir -p alpine

##
## Generate docker-entrypoint.sh
##
sed 's/gosu/su-exec/g' ./docker-entrypoint.sh > ./alpine/docker-entrypoint.sh
chmod +x ./alpine/docker-entrypoint.sh

##
## Generate Dockerfile
##
sed \
  -e 's/FROM.*/FROM eclipse-temurin:8-jre-alpine/' \
  -e 's/BUILD_FDB=true/BUILD_FDB=false/' \
  -e 's/apt-get update/apk add --no-cache\\/' \
  -e 's/DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends/  bash \\\n    libstdc++/' \
  -e 's/gosu/su-exec/' \
  -e 's/groupadd --system --gid=942 warp10/addgroup -S -g 942 warp10/' \
  -e 's@useradd --system --gid warp10 --uid=942 --home-dir=${WARP10_HOME} --shell=/bin/bash warp10@adduser -S -u 942 -D -G warp10 -H -h ${WARP10_HOME} -s /bin/bash warp10@' \
  -e 's@\./docker-entrypoint.sh@\./alpine/docker-entrypoint.sh@' \
  ./ubuntu/Dockerfile > ./alpine/Dockerfile
