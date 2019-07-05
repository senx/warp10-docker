#!/bin/bash
#
#   Copyright 2018  SenX S.A.S.
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


IN_MEMORY_CONFIG=${WARP10_CONFIG_DIR}/20_in-memory.conf

warp10_pid=
sensision_pid=

source ${WARP10_HOME}/bin/setup.sh

 # SIGTERM-handler
term_handler() {
  echo "Stopping Warp 10"
  if [ $warp10_pid -ne 0 ]; then
    kill -SIGTERM "$warp10_pid"
  fi

  echo "Stopping Sensision"
  if [ $sensision_pid -ne 0 ]; then
    kill -SIGTERM "$sensision_pid"
  fi

  #
  # Wait for non child process to finish
  #
  while [ -e /proc/${warp10_pid} ] || [ -e /proc/${sensision_pid} ]
  do
    sleep 0.1
  done

  echo "All process are stopped"
  exit 143; # 128 + 15 -- SIGTERM
}

# Configuration file present launch Warp 10, Sensision and Quantum
if [ -e ${WARP10_CONF} ]; then

  #
  # Standalone IN_MEMORY configuration
  #
  if [ "${IN_MEMORY}" = "true" ]; then
    echo "Setting 'IN MEMORY' parameters"
    echo "leveldb.home = /dev/null" > ${IN_MEMORY_CONFIG}
    echo "in.memory = true" >> ${IN_MEMORY_CONFIG}
    echo "in.memory.chunked = true" >> ${IN_MEMORY_CONFIG}
    echo "in.memory.chunk.count = 2" >> ${IN_MEMORY_CONFIG}
    echo "in.memory.chunk.length = 86400000000" >> ${IN_MEMORY_CONFIG}
    echo "in.memory.load = ${WARP10_DATA_DIR}/memory.dump" >> ${IN_MEMORY_CONFIG}
    echo "in.memory.dump = ${WARP10_DATA_DIR}/memory.dump" >> ${IN_MEMORY_CONFIG}
  else
    echo "Unsetting 'IN MEMORY' parameters"
    echo "leveldb.home = \${standalone.home}/leveldb" > ${IN_MEMORY_CONFIG}
    echo "in.memory = false" >> ${IN_MEMORY_CONFIG}
  fi

  # # Custom macro mode
  # if [ "${CUSTOM_MACRO}" = "true" ]; then
  #   echo "Configure macros directory"
  #   sed -i "s~^warpscript.repository.directory = .*~warpscript.repository.directory = ${WARP10_MACROS}~" ${WARP10_CONF}
  #   sed -i 's~^warpscript.repository.refresh = 60000~warpscript.repository.refresh = 1000~' ${WARP10_CONF}
  # fi

  chown -R warp10:warp10 ${WARP10_CONFIG_DIR}

  echo "Configuration File exists - Update Quantum port (8081)"
  sed -i 's/^quantum\.port.*/quantum\.port = 8081/' ${WARP10_CONF}

  echo "Launch Warp10"
  sed -i -e "s/127.0.0.1/0.0.0.0/g" ${WARP10_CONF}
  ${WARP10_HOME}/bin/warp10-standalone.init start
  warp10_pid=`cat ${WARP10_HOME}/logs/warp10.pid`
  echo "Warp10 running, pid=${warp10_pid}"

  # Launching sensision
  ${SENSISION_HOME}/bin/sensision.init start
  sensision_pid=`cat ${SENSISION_HOME}/logs/sensision.pid`
  echo "Sensision running, pid=${sensision_pid}"

  # TODO ends this script if warp10 is not running properly
  echo "All process are running"

  trap 'kill ${!}; term_handler' SIGTERM SIGKILL SIGINT

  # wait indefinitely
  tail -f /dev/null & wait ${!}

else
  echo "ERROR: Unable to launch Warp10, configuration missing"
  echo "WARNING: Since version 2.1.0, Warp 10 can use multiple configuration files. The files have to be present in ${WARP10_CONFIG_DIR}"
  echo "WARNING: Default configuration file must be named ${WARP10_CONFIG_DIR}/00_warp.conf"
  exit -1
fi
