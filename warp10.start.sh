#!/bin/bash

source ${WARP10_HOME}/bin/setup.sh

# Configuration file present launch Warp10, Sensision and Quantum
if [ -e ${WARP10_VOLUME}/warp10/etc/conf-standalone.conf ]; then
  # Legacy warp10 template with no revision
  if ! grep -q  REVISION_TAG ${WARP10_VOLUME}/warp10/etc/conf-standalone.conf; then
    # REPLACE Hard version link with soft links
    sed -i 's_/opt/warp10-[0-9]+\.[0-9]+\.[0-9]+\(-rc[0-9]+\)?\(-[0-9]+-[a-z0-9]+\)*_\$\{standalone\.home\}_g' ${WARP10_VOLUME}/warp10/etc/conf-standalone.conf
    # Adds new var in the file
    echo >> ${WARP10_VOLUME}/warp10/etc/conf-standalone.conf
    echo "//" >> ${WARP10_VOLUME}/warp10/etc/conf-standalone.conf
    echo "// Directory of Warp10 standalone install" >> ${WARP10_VOLUME}/warp10/etc/conf-standalone.conf
    echo "//" >> ${WARP10_VOLUME}/warp10/etc/conf-standalone.conf
    echo "standalone.home = /opt/warp10" >> ${WARP10_VOLUME}/warp10/etc/conf-standalone.conf

    sed -i 's_/opt/warp10-[0-9]+\.[0-9]+\.[0-9]+\(-rc[0-9]+\)?\(-[0-9]+-[a-z0-9]+\)*_/opt/warp10_g' ${WARP10_VOLUME}/warp10/etc/log4j.properties
    # ADDS REVISION TO THE TEMPLATE
    sed -i "4s/\/\/.*/\/\/ REVISION_TAG=1\.0/" ${WARP10_VOLUME}/warp10/etc/conf-standalone.conf
  fi
  # Standalone mode
  if [ "${IN_MEMORY}" = "true" ]; then
    echo "Setting 'IN MEMORY' parameters"
    sed -i 's~^leveldb.home = ${standalone.home}/leveldb~leveldb.home = /dev/null~' ${WARP10_HOME}/etc/conf-standalone.conf
    sed -i 's~^in.memory = false~in.memory = true~' ${WARP10_HOME}/etc/conf-standalone.conf
    sed -i 's~^//in.memory.chunked = true~in.memory.chunked = true~' ${WARP10_HOME}/etc/conf-standalone.conf
    sed -i 's~^//in.memory.chunk.count =~in.memory.chunk.count = 2~' ${WARP10_HOME}/etc/conf-standalone.conf
    sed -i 's~^//in.memory.chunk.length =~in.memory.chunk.length = 86400000000~' ${WARP10_HOME}/etc/conf-standalone.conf
    sed -i "s~^#in.memory.load =~in.memory.load = ${WARP10_HOME}/data/dump~" ${WARP10_HOME}/etc/conf-standalone.conf
    sed -i "s~^#in.memory.dump =~in.memory.dump = ${WARP10_HOME}/data/dump~" ${WARP10_HOME}/etc/conf-standalone.conf
  fi
  # Custom macro mode
  if [ "${CUSTOM_MACRO}" = "true" ]; then
    echo "Configure macros directory"
    sed -i "s~^warpscript.repository.directory = .*~warpscript.repository.directory = ${WARP10_MACROS}~" ${WARP10_HOME}/etc/conf-standalone.conf
    sed -i 's~^warpscript.repository.refresh = 60000~warpscript.repository.refresh = 1000~' ${WARP10_HOME}/etc/conf-standalone.conf
  fi

  # Legacy sensision template
  if ! grep -q  REVISION_TAG ${WARP10_VOLUME}/sensision/etc/sensision.conf; then
    # REPLACE HARD LINKS IN SENSISION CONFIGURATION
    sed -i 's/^sensision\.home.*/sensision\.home = \/opt\/sensision/' ${WARP10_VOLUME}/sensision/etc/sensision.conf
    sed -i 's/^sensision\.scriptrunner\.root.*/sensision\.scriptrunner\.root= \/opt\/sensision\/scripts/' ${WARP10_VOLUME}/sensision/etc/sensision.conf

    # ADDS REVISION TO THE TEMPLATE
    sed -i "10s/.*/## REVISION_TAG=1\.0/" ${WARP10_VOLUME}/sensision/etc/sensision.conf
  fi

  echo "Configuration File exists - Update Quantum port (8081)"
  sed -i 's/^quantum\.port.*/quantum\.port = 8081/' ${WARP10_HOME}/etc/conf-standalone.conf

  echo "Launch Warp10"
  sed -i -e "s/127.0.0.1/0.0.0.0/g" ${WARP10_HOME}/etc/conf-standalone.conf
  ${WARP10_HOME}/bin/warp10-standalone.init start
  echo "Warp10 running"

  # Launching sensision
  ${SENSISION_HOME}/bin/sensision.init start
  echo "Sensision running"

  # TODO ends this script if warp10 is not running properly
  echo "All process are running"
  while true; do sleep 1; done
else
  echo "Unable to launch Warp10, configuration missing"
  exit -1
fi
