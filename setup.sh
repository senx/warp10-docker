#!/usr/bin/env bash
#
#   Copyright 2020-2022  SenX S.A.S.
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

set -euo pipefail

# WARP10 - install and manage upgrade
if [ ! -d "${WARP10_DATA_DIR}" ]; then
  echo "Install Warp 10"
  "${WARP10_HOME}/bin/warp10-standalone.init" bootstrap
  touch "${WARP10_HOME}/logs/warpscript.out"
  touch "${WARP10_HOME}/logs/warp10.log"
else
  echo "Warp 10 already installed"

  # shellcheck disable=SC2115
  rm -rf "${WARP10_HOME}/etc"
  ln -s "${WARP10_DATA_DIR}/etc" "${WARP10_HOME}/etc"

  rm -rf "${WARP10_HOME}/leveldb"
  ln -s "${WARP10_DATA_DIR}/leveldb" "${WARP10_HOME}/leveldb"

  rm -rf "${WARP10_HOME}/macros"
  ln -s "${WARP10_DATA_DIR}/macros" "${WARP10_HOME}/macros"

  rm -rf "${WARP10_HOME}/warpscripts"
  ln -s "${WARP10_DATA_DIR}/warpscripts" "${WARP10_HOME}/warpscripts"

  rm -rf "${WARP10_HOME}/logs"
  ln -s "${WARP10_DATA_DIR}/logs" "${WARP10_HOME}/logs"

  rm -rf "${WARP10_HOME}/jars"
  ln -s "${WARP10_DATA_DIR}/jars" "${WARP10_HOME}/jars"

  # shellcheck disable=SC2115
  rm -rf "${WARP10_HOME}/lib"
  ln -s "${WARP10_DATA_DIR}/lib" "${WARP10_HOME}/lib"

  rm -rf "${WARP10_HOME}/datalog"
  ln -s "${WARP10_DATA_DIR}/datalog" "${WARP10_HOME}/datalog"

  rm -rf "${WARP10_HOME}/datalog_done"
  ln -s "${WARP10_DATA_DIR}/datalog_done" "${WARP10_HOME}/datalog_done"

  if [ -L "${WARP10_HOME}/hfiles" ]; then
    ln -s "${WARP10_DATA_DIR}/hfiles" "${WARP10_HOME}/hfiles"
  fi
fi

# HFiles
if [ ! -d "${WARP10_DATA_DIR}/hfiles" ]; then
  echo "Creating HFiles directory"
  mkdir "${WARP10_DATA_DIR}/hfiles"
  ln -s "${WARP10_DATA_DIR}/hfiles" "${WARP10_HOME}/hfiles"
fi

# Sensision install
if [ ! -d "${SENSISION_DATA_DIR}" ]; then
  echo "Install Sensision"
  # Stop/start to init config
  "${SENSISION_HOME}/bin/sensision.init" bootstrap
  SENSISION_TOKENS="${SENSISION_HOME}/etc/sensision.tokens"
  TOKEN_TYPE="read"
  READ_TOKEN="$(cat "${SENSISION_TOKENS}" | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w "${TOKEN_TYPE}" | cut -d'|' -f 3 | tr -d '\n\r')"
  MACRO_SECRET="$(date | md5sum | cut -d'-' -f 1)"
  echo "warpscript.macroconfig.secret = ${MACRO_SECRET}" >> "${WARP10_DATA_DIR}/etc/conf.d/20-sensision.conf"
  echo "token@senx/sensision/token = ${READ_TOKEN}" >> "${WARP10_DATA_DIR}/etc/conf.d/20-sensision.conf"
else
  echo "Sensision already installed"
  #clean
  # shellcheck disable=SC2115
  rm -rf "${SENSISION_HOME}/etc" "${SENSISION_HOME}/scripts" "${SENSISION_HOME}/logs" "${SENSISION_HOME}/metrics" "${SENSISION_HOME}/targets" "${SENSISION_HOME}/queued"
  # link sensision
  ln -s "${SENSISION_DATA_DIR}/etc" "${SENSISION_HOME}/etc"
  ln -s "${SENSISION_DATA_DIR}/scripts" "${SENSISION_HOME}/scripts"
  ln -s "${SENSISION_DATA_DIR}/logs" "${SENSISION_HOME}/logs"
  ln -s "${SENSISION_DATA_DIR}/metrics" "${SENSISION_HOME}/metrics"
  ln -s "${SENSISION_DATA_DIR}/targets" "${SENSISION_HOME}/targets"
  ln -s "${SENSISION_DATA_DIR}/queued" "${SENSISION_HOME}/queued"
fi

# Disable failing as the chown could fail, for example when hfiles contains volumes mounted read only
set +e
chown -Rf warp10:warp10 "${WARP10_DATA_DIR}"
chown -Rf sensision:sensision "${SENSISION_DATA_DIR}"
