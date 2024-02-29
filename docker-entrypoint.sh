#!/usr/bin/env bash

##
## Shebang must be bash in order to accept environment variables with dot in the name (ie: accelerator.chunk.length)
##


#
#   Copyright 2022-2024  SenX S.A.S.
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

FLAVOR=${FLAVOR:=standalone}
WARP10_CONFIG_DIR=${WARP10_HOME}/etc/conf.d
WARP10_DATA_DIR=${WARP10_VOLUME}/warp10
FIRSTINIT_FILE=${WARP10_DATA_DIR}/.firstinit

moveDir() {
  dir=$1
  if [ -e "${WARP10_DATA_DIR}/${dir}" ]; then
      rm -rf "${WARP10_HOME:?}/${dir}"
  else
    mv "${WARP10_HOME}/${dir}" "${WARP10_DATA_DIR}"
  fi

  ln -s "${WARP10_DATA_DIR}/${dir}" "${WARP10_HOME}/${dir}"
  chown -h warp10:warp10 "${WARP10_HOME}/${dir}"
}


##
## Modify start script to run java process in foreground with exec
##
sed -i -e 's@.*\(${JAVACMD} ${JAVA_OPTS} -cp ${WARP10_CP} ${WARP10_CLASS} ${CONFIG_FILES}\).*@  exec \1@' "${WARP10_HOME}/bin/warp10.sh"

##
## At the first run,
## fill up the data dir if we don't have a volume
## Generate secrets and token file
##
if [ ! -f "${FIRSTINIT_FILE}" ]; then
  "${WARP10_HOME}/bin/warp10.sh" init "${FLAVOR}" >/dev/null 2>&1

  ##
  ## Configure Warp 10
  ##
  sed -i -e 's|^#WARP10_USER=.*|WARP10_USER=warp10|' -e 's|^#WARP10_EXT_CONFIG_DIR=.*|WARP10_EXT_CONFIG_DIR=/config.extra|' "${WARP10_HOME}/etc/warp10-env.sh"

  ##
  ## Listen to all interface, enable SensisionWarpScriptExtension and TokenWarpScriptExtension
  ##
  sed -i -e 's|^#warpscript.extension.sensision|warpscript.extension.sensision|g' "${WARP10_CONFIG_DIR}/99-init.conf"
  {
    echo 'standalone.host = 0.0.0.0'
    echo 'warpscript.extension.token = io.warp10.script.ext.token.TokenWarpScriptExtension'
    echo 'debug.capability = false'
  } >> "${WARP10_CONFIG_DIR}/99-docker.conf"

  ##
  ## Set configuration for WarpStudio
  ##
  {
    echo 'warp10.plugin.warpstudio = io.warp10.plugins.warpstudio.WarpStudioPlugin'
    echo 'warpstudio.port = 8081'
    echo 'warpstudio.host = ${standalone.host}'
  } >> "${WARP10_CONFIG_DIR}/99-io.warp10-warp10-plugin-warpstudio.conf"

  # TODO: enable this when HFStore has been upgraded for 3.0
  # ##
  # ## Set configuration for HFStore
  # ##
  # unzip -q "${WARP10_HOME}/lib/warp10-ext-hfstore-${HFSTORE_VERSION}.jar" warp10-ext-hfstore.conf
  # mv warp10-ext-hfstore.conf "${WARP10_CONFIG_DIR}/99-io.senx-warp10-ext-hfstore.conf"


  ##
  ## Enable Sensision
  ##
  if [ "true" != "${NO_SENSISION:-}" ]; then
    ##
    ## Generate read/write token for sensision for a period of 100 years. We use 'sensision' as application name.
    ## Define token as MACROCONFIG key for runner script
    ##
    tokens=$("${WARP10_HOME}"/bin/warp10.sh tokengen "${WARP10_HOME}/tokens/sensision-tokengen.mc2" 2>/dev/null)
    SENSISION_READ_TOKEN=$(echo "${tokens}" | grep '"token"' | tail -1 | sed -e 's/.*" : "//' -e 's/".*//')
    SENSISION_WRITE_TOKEN=$(echo "${tokens}" | grep '"token"' | head -1 | sed -e 's/.*" : "//' -e 's/".*//')
    echo "sensisionReadToken@/sensision=${SENSISION_READ_TOKEN}" >> "${WARP10_CONFIG_DIR}"/99-sensision-secrets.conf
    echo "sensisionWriteToken@/sensision=${SENSISION_WRITE_TOKEN}" >> "${WARP10_CONFIG_DIR}"/99-sensision-secrets.conf
    chown warp10:warp10 "${WARP10_CONFIG_DIR}"/99-sensision-secrets.conf
  fi

  ##
  ## Remove templates
  ##
  rm -rf "${WARP10_HOME}/conf.templates"
fi

##
## Move files to data dir
##
mkdir -p "${WARP10_DATA_DIR}"
moveDir "calls"
moveDir "datalog"
moveDir "etc"
moveDir "hfiles"
moveDir "jars"
[ "standalone" = "${FLAVOR}" ] && moveDir "leveldb"
moveDir "lib"
moveDir "logs"
moveDir "macros"
moveDir "runners"
moveDir "tokens"

if [ ! -f "${FIRSTINIT_FILE}" ]; then
  touch "${FIRSTINIT_FILE}"

  ##
  ## Fix permissions
  ##
  chown -RHh warp10:warp10 "${WARP10_HOME}"
  chown -RHh warp10:warp10 "${WARP10_VOLUME}"
  chown warp10:warp10 "${WARP10_HOME}"
fi

echo "Starting"
exec gosu warp10 "$@"
