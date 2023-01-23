#!/usr/bin/env bash

##
## Shebang must be bash in order to accept environment variables with dot in the name (ie: accelerator.chunk.length)
##


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

FIRSTINIT_FILE=${WARP10_HOME}/.firstinit

##
## At the first run,
## fill up the data dir if we don't have a volume
## Generate secrets and token file
##
if [ -e "${FIRSTINIT_FILE}" ]; then
  ##
  ## Populate the volume
  ##
  if [ ! -e "${WARP10_DATA_DIR}" ]; then
    mv "${WARP10_VOLUME}".bak/* "${WARP10_VOLUME}";
  fi

  echo "Generate secrets"
  java -cp "${WARP10_HOME}"/bin/warp10-*.jar -Dfile.encoding=UTF-8 io.warp10.GenerateCryptoKey "${WARP10_CONFIG_DIR}"/*.conf

  ##
  ## Token management
  ##
  if [ ! -e "${WARP10_HOME}"/etc/initial.tokens ]; then
    ##
    ## Generate read/write tokens valid for a period of 100 years. We use 'io.warp10.bootstrap' as application name.
    ##
    gosu warp10 java -cp "${WARP10_HOME}"/bin/warp10-"${WARP10_VERSION}".jar -Dfile.encoding=UTF-8 io.warp10.worf.TokenGen "${WARP10_CONFIG_DIR}"/00-secrets.conf "${WARP10_CONFIG_DIR}"/00-warp.conf "${WARP10_HOME}"/templates/warp10-tokengen.mc2 "${WARP10_HOME}"/etc/initial.tokens
    sed -i 's/^.\{1\}//;$ s/.$//' "${WARP10_HOME}"/etc/initial.tokens # Remove first and last character

    ##
    ## Generate read/write token for sensision for a period of 100 years. We use 'sensision' as application name.
    ## Define token as MACROCONFIG key for runner script
    ##
    gosu warp10 java -cp "${WARP10_HOME}"/bin/warp10-"${WARP10_VERSION}".jar -Dfile.encoding=UTF-8 io.warp10.worf.TokenGen "${WARP10_CONFIG_DIR}"/00-secrets.conf "${WARP10_CONFIG_DIR}"/00-warp.conf "${WARP10_HOME}"/templates/sensision-tokengen.mc2 "${WARP10_HOME}"/etc/sensision.tokens
    SENSISION_READ_TOKEN=$(sed -e 's/.*,"id":"SensisionRead","token":"//' -e 's/".*//' /opt/warp10/etc/sensision.tokens)
    SENSISION_WRITE_TOKEN=$(sed -e 's/.*,"id":"SensisionWrite","token":"//' -e 's/".*//' /opt/warp10/etc/sensision.tokens)
    echo "sensisionReadToken@/sensision=${SENSISION_READ_TOKEN}" >> "${WARP10_CONFIG_DIR}"/99-sensision-secrets.conf
    echo "sensisionWriteToken@/sensision=${SENSISION_WRITE_TOKEN}" >> "${WARP10_CONFIG_DIR}"/99-sensision-secrets.conf
    chown warp10:warp10 "${WARP10_CONFIG_DIR}"/99-sensision-secrets.conf

  fi

  rm -rf "${WARP10_VOLUME}".bak
  rm "${FIRSTINIT_FILE}"
fi


##
## Standalone IN_MEMORY configuration
##
IN_MEMORY_CONFIG=${WARP10_HOME}/etc/conf.d/30-in-memory.conf
if [ "true" = "${IN_MEMORY:-}" ]; then
  echo "'IN MEMORY' mode is enabled"
  sed -i -e 's/.*leveldb.home =.*/leveldb.home = \/dev\/null/g' "${IN_MEMORY_CONFIG}"
  sed -i -e 's/.*in.memory =.*/in.memory = true/g' "${IN_MEMORY_CONFIG}"
  sed -i -e 's/.*in.memory.chunked =.*/in.memory.chunked = true/g' "${IN_MEMORY_CONFIG}"
  sed -i -e 's/.*in.memory.chunk.count =.*/in.memory.chunk.count = 2/g' "${IN_MEMORY_CONFIG}"
  sed -i -e 's/.*in.memory.chunk.length =.*/in.memory.chunk.length = 86400000000/g' "${IN_MEMORY_CONFIG}"
  sed -i -e "s~.*in.memory.load =.*~in.memory.load = ${WARP10_DATA_DIR}/memory.dump~g" "${IN_MEMORY_CONFIG}"
  sed -i -e "s~.*in.memory.dump =.*~in.memory.dump = ${WARP10_DATA_DIR}/memory.dump~g" "${IN_MEMORY_CONFIG}"
else
  echo "'IN MEMORY' mode is disabled"
  sed -i -e "s~.*leveldb.home =.*~leveldb.home = \${standalone.home}/leveldb~g" "${IN_MEMORY_CONFIG}"
  sed -i -e 's/.*in.memory = .*/in.memory = false/g' "${IN_MEMORY_CONFIG}"
fi


##
## Disable sensision if asked
##
if [ "true" = "${NO_SENSISION:-}" ] && [ -f "${WARP10_HOME}"/warpscripts/sensision/60000/update-sensision.mc2 ]; then
  echo "'NO_SENSISION' mode is enabled"
  mv "${WARP10_HOME}"/warpscripts/sensision/60000/update-sensision.mc2{,.DISABLE}
fi


echo "Start Warp 10"
exec gosu warp10 "$@"
