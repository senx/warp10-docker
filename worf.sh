#!/bin/sh

source ${WARP10_HOME}/bin/setup.sh

${JAVA_HOME}/bin/java -cp ${WARP10_HOME}/bin/warp10-$WARP10_VERSION.jar io.warp10.worf.Worf -i ${WARP10_HOME}/etc/conf-standalone.conf
