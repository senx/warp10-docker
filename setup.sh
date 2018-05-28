#!/usr/bin/env bash
# Create user warp10
if [ "`which useradd`" = "" ]; then
  adduser -D -s -H -h ${WARP10_HOME} -s /bin/bash warp10
  adduser -D -s -H -h ${SENSISION_HOME} -s /bin/bash sensision
  addgroup sensision warp10
else
  useradd -d ${WARP10_HOME} -M -r warp10
  useradd -d ${SENSISION_HOME} -M -r sensision -G warp10
fi

chown -R warp10:warp10 ${WARP10_HOME}*
chown -R sensision:warp10 ${SENSISION_HOME}*

# WARP10 - install and manage upgrade
# REPLACE HARD LINKS AND USE DATA DIR
#sed -i "s/^#WARP10_HOME.*/WARP10_HOME=\/opt\/warp10/" ${WARP10_HOME}/bin/warp10-standalone.sh
#sed -i "s~^#WARP10_DATA_DIR.*~WARP10_DATA_DIR=${WARP10_DATA_DIR}~" ${WARP10_HOME}/bin/warp10-standalone.sh

if [ ! -d ${WARP10_DATA_DIR} ]; then
  mkdir -p ${WARP10_DATA_DIR}
  chown warp10:warp10 ${WARP10_DATA_DIR}
  chmod 775 ${WARP10_DATA_DIR}

  echo "Install Warp10"
  ${WARP10_HOME}/bin/warp10-standalone.init bootstrap
else
  echo "Warp10 already installed"

  rm -rf ${WARP10_HOME}/etc
  ln -s ${WARP10_VOLUME}/warp10/etc ${WARP10_HOME}/etc

  rm -rf ${WARP10_HOME}/leveldb
  ln -s ${WARP10_VOLUME}/warp10/leveldb ${WARP10_HOME}/leveldb

  rm -rf ${WARP10_HOME}/macros
  ln -s ${WARP10_VOLUME}/warp10/macros ${WARP10_HOME}/macros

  rm -rf ${WARP10_HOME}/warpscripts
  ln -s ${WARP10_VOLUME}/warp10/warpscripts ${WARP10_HOME}/warpscripts

  rm -rf ${WARP10_HOME}/logs
  ln -s ${WARP10_VOLUME}/warp10/logs ${WARP10_HOME}/logs

  rm -rf ${WARP10_HOME}/jars
  ln -s ${WARP10_VOLUME}/warp10/jars ${WARP10_HOME}/jars

  rm -rf ${WARP10_HOME}/lib
  ln -s ${WARP10_VOLUME}/warp10/lib ${WARP10_HOME}/lib

  rm -rf ${WARP10_HOME}/datalog
  ln -s ${WARP10_VOLUME}/warp10/datalog ${WARP10_HOME}/datalog

  rm -rf ${WARP10_HOME}/datalog_done
  ln -s ${WARP10_VOLUME}/warp10/datalog_done ${WARP10_HOME}/datalog_done
fi

# Sensision install
if [ ! -d ${SENSISION_DATA_DIR} ]; then
  echo "Install Sensision"
  # Stop/start to init config
  ${SENSISION_HOME}/bin/sensision.init start && ${SENSISION_HOME}/bin/sensision.init stop
else
  echo "Sensision already installed"
  #clean
  rm -rf ${SENSISION_HOME}/etc ${SENSISION_HOME}/scripts ${SENSISION_HOME}/logs ${SENSISION_HOME}/metrics ${SENSISION_HOME}/targets ${SENSISION_HOME}/queued
  # link sensision
  ln -s ${WARP10_VOLUME}/sensision/etc ${SENSISION_HOME}/etc
  ln -s ${WARP10_VOLUME}/sensision/scripts ${SENSISION_HOME}/scripts
  ln -s ${WARP10_VOLUME}/sensision/logs ${SENSISION_HOME}/logs
  ln -s ${WARP10_VOLUME}/sensision/metrics ${SENSISION_HOME}/metrics
  ln -s ${WARP10_VOLUME}/sensision/targets ${SENSISION_HOME}/targets
  ln -s ${WARP10_VOLUME}/sensision/queued ${SENSISION_HOME}/queued
fi

# # REPLACE HARD LINKS
# sed -i 's/^standalone\.home.*/standalone\.home = \/opt\/warp10/' ${WARP10_HOME}/etc/conf-standalone
# sed -i "s/\/opt\/warp10-${WARP10_VERSION}/\/opt\/warp10/" ${WARP10_HOME}/etc/log4j.properties

# sed -i "s/^sensision\.home.*/sensision\.home = \/opt\/sensision/" ${SENSISION_HOME}/etc/sensision.conf
# sed -i "s/^sensision\.scriptrunner\.root.*/sensision\.scriptrunner\.root = \/opt\/sensision\/scripts/" ${SENSISION_HOME}/etc/sensision.conf
# sed -i "s/sensisionLog\.File=.*/sensisionLog\.File=\/opt\/sensision\/logs\/nohup.out/" ${SENSISION_HOME}/etc/log4j.properties
