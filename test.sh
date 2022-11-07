#!/usr/bin/env sh
#
#   Copyright 2021-2022  SenX S.A.S.
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

#CMD=docker run -d -p 8080:8080 -p 8081:8081 ${{ secrets.DOCKER_USERNAME }}/warp10:${TAG}-test
CMD=$@

echo "Run docker image"
id=$(${CMD})

echo "Wait for container to start-up"
if ! timeout 60s sh -c "while ! curl -s --fail http://localhost:8080/api/v0/check; do sleep 1; done";
then
   echo "Failed to start container"
   exit 1
fi

echo "Get tokens"
READ_TOKEN=$(docker exec -i "${id}" tail -n 1 /opt/warp10/etc/initial.tokens | sed -e 's/{"read":{"token":"//' -e 's/".*//')
WRITE_TOKEN=$(docker exec -i "${id}" tail -n 1 /opt/warp10/etc/initial.tokens | sed -e 's/.*,"write":{"token":"//' -e 's/".*//')

echo "Write data"
if ! curl -s -H "X-Warp10-Token: ${WRITE_TOKEN}" http://127.0.0.1:8080/api/v0/update --data-binary '// test{} 42'; then
  echo "Failed to write data"
  docker stop "${id}"
  exit 1
fi

echo "Read data"
res=$(curl -s "http://127.0.0.1:8080/api/v0/fetch?token=${READ_TOKEN}&selector=~.*\{\}&now=now&timespan=-1" | cut -d ' ' -f3)
if [ "${res}" != "42" ]; then
  echo "Failed to compare write data with read data"
  echo "Value read: ${res}"
  docker stop "${id}"
  exit 1
fi

echo "Delete data"
res=$(curl -s -H "X-Warp10-Token:${WRITE_TOKEN}" "http://127.0.0.1:8080/api/v0/delete?selector=test%7B%7D&deleteall" | cut -c -32)
if [ "${res}" != "test{.app=io.warp10.bootstrap}{}" ]; then
  echo "Failed to delete data"
  echo "Result: ${res}"
  docker stop "${id}"
  exit 1
fi

echo "Check if data was deleted"
res=$(curl -s "http://127.0.0.1:8080/api/v0/fetch?token=${READ_TOKEN}&selector=~.*\{\}&now=now&timespan=-1" | cut -d ' ' -f3)
if [ "${res}" != "" ]; then
  echo "Data is still present"
  echo "Value read: ${res}"
  docker stop "${id}"
  exit 1
fi

echo "Test WarpStudio"
res=$(curl -Is http://127.0.0.1:8081/ | head -1)
if [ "${res%?}" != "HTTP/1.1 200 OK" ]; then
  echo "Failed to test WarpStudio URL"
  echo "Curl result: ${res}"
  docker ps -a
  docker stop "${id}"
  exit 1
fi

echo "Stop container"
docker stop "${id}"

echo "Test successful"
