#!/usr/bin/env bash
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

chown -R warp10:warp10 ${WARP10_HOME} ${WARP10_DATA_DIR}
chown -R sensision:warp10 ${SENSISION_HOME} ${SENSISION_DATA_DIR}

# WARP10 - install and manage upgrade
if [ ! -d ${WARP10_DATA_DIR} ]; then
  echo "Install Warp 10™"
  ${WARP10_HOME}/bin/warp10-standalone.init bootstrap
else
  echo "Warp 10™ already installed"

  rm -rf ${WARP10_HOME}/etc
  ln -s ${WARP10_DATA_DIR}/etc ${WARP10_HOME}/etc

  rm -rf ${WARP10_HOME}/leveldb
  ln -s ${WARP10_DATA_DIR}/leveldb ${WARP10_HOME}/leveldb

  rm -rf ${WARP10_HOME}/macros
  ln -s ${WARP10_DATA_DIR}/macros ${WARP10_HOME}/macros

  rm -rf ${WARP10_HOME}/warpscripts
  ln -s ${WARP10_DATA_DIR}/warpscripts ${WARP10_HOME}/warpscripts

  rm -rf ${WARP10_HOME}/logs
  ln -s ${WARP10_DATA_DIR}/logs ${WARP10_HOME}/logs

  rm -rf ${WARP10_HOME}/jars
  ln -s ${WARP10_DATA_DIR}/jars ${WARP10_HOME}/jars

  rm -rf ${WARP10_HOME}/lib
  ln -s ${WARP10_DATA_DIR}/lib ${WARP10_HOME}/lib

  rm -rf ${WARP10_HOME}/datalog
  ln -s ${WARP10_DATA_DIR}/datalog ${WARP10_HOME}/datalog

  rm -rf ${WARP10_HOME}/datalog_done
  ln -s ${WARP10_DATA_DIR}/datalog_done ${WARP10_HOME}/datalog_done
fi

# Sensision install
if [ ! -d ${SENSISION_DATA_DIR} ]; then
  echo "Install Sensision"
  # Stop/start to init config
  ${SENSISION_HOME}/bin/sensision.init bootstrap
else
  echo "Sensision already installed"
  #clean
  rm -rf ${SENSISION_HOME}/etc ${SENSISION_HOME}/scripts ${SENSISION_HOME}/logs ${SENSISION_HOME}/metrics ${SENSISION_HOME}/targets ${SENSISION_HOME}/queued
  # link sensision
  ln -s ${SENSISION_DATA_DIR}/etc ${SENSISION_HOME}/etc
  ln -s ${SENSISION_DATA_DIR}/scripts ${SENSISION_HOME}/scripts
  ln -s ${SENSISION_DATA_DIR}/logs ${SENSISION_HOME}/logs
  ln -s ${SENSISION_DATA_DIR}/metrics ${SENSISION_HOME}/metrics
  ln -s ${SENSISION_DATA_DIR}/targets ${SENSISION_HOME}/targets
  ln -s ${SENSISION_DATA_DIR}/queued ${SENSISION_HOME}/queued
fi
