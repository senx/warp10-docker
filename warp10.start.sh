#!/bin/bash

if [ ! -e ${WARP10_VOLUME}/warp10/etc/conf-standalone.conf ]
then

  ${WARP10_HOME}/bin/warp10-standalone.bootstrap
  ${SENSISION_HOME}/bin/sensision.bootstrap
  mkdir -p ${WARP10_VOLUME}/warp10
  mkdir -p ${WARP10_VOLUME}/sensision
  mv ${WARP10_HOME}/etc ${WARP10_VOLUME}/warp10/etc
  ln -s ${WARP10_VOLUME}/warp10/etc ${WARP10_HOME}/etc
  mv ${WARP10_HOME}/data ${WARP10_VOLUME}/warp10/data
  ln -s ${WARP10_VOLUME}/warp10/data ${WARP10_HOME}/data
  mv ${WARP10_HOME}/macros ${WARP10_VOLUME}/warp10/macros
  ln -s ${WARP10_VOLUME}/warp10/macros ${WARP10_HOME}/macros
  mv ${WARP10_HOME}/warpscripts ${WARP10_VOLUME}/warp10/warpscripts
  ln -s ${WARP10_VOLUME}/warp10/warpscripts ${WARP10_HOME}/warpscripts
  mv ${WARP10_HOME}/logs ${WARP10_VOLUME}/warp10/logs
  ln -s ${WARP10_VOLUME}/warp10/logs ${WARP10_HOME}/logs
  mv ${SENSISION_HOME}/etc ${WARP10_VOLUME}/sensision/etc
  ln -s ${WARP10_VOLUME}/sensision/etc ${SENSISION_HOME}/etc
  mv ${SENSISION_HOME}/data ${WARP10_VOLUME}/sensision/data
  ln -s ${WARP10_VOLUME}/sensision/data ${SENSISION_HOME}/data
  mv ${SENSISION_HOME}/scripts ${WARP10_VOLUME}/sensision/scripts
  ln -s ${WARP10_VOLUME}/sensision/scripts ${SENSISION_HOME}/scripts
  chown -R warp10:warp10 ${WARP10_VOLUME}
  chown -R sensision:sensision ${WARP10_VOLUME}/sensision

  sed -i -e "s/127.0.0.1/0.0.0.0/g" ${WARP10_HOME}/etc/conf-standalone.conf
else
  echo "File already exists"
  # Create user warp10
  if [ "`which useradd`" = "" ]
  then
    adduser -D -s -H -h ${WARP10_HOME} -s /bin/bash warp10
    adduser -D -s -H -h ${SENSISION_HOME} -s /bin/bash sensision
  else
    useradd -d ${WARP10_HOME} -M -r warp10
    useradd -d ${SENSISION_HOME} -M -r sensision
  fi
  rm -fr ${WARP10_HOME}/etc   ${WARP10_HOME}/data   ${WARP10_HOME}/macros  ${WARP10_HOME}/warpscripts ${WARP10_HOME}/logs
  rm -fr  ${SENSISION_HOME}/etc ${SENSISION_HOME}/data  ${SENSISION_HOME}/scripts
  ln -s ${WARP10_VOLUME}/warp10/etc ${WARP10_HOME}/etc
  ln -s ${WARP10_VOLUME}/warp10/data ${WARP10_HOME}/data
  ln -s ${WARP10_VOLUME}/warp10/macros ${WARP10_HOME}/macros
  ln -s ${WARP10_VOLUME}/warp10/warpscripts ${WARP10_HOME}/warpscripts
  ln -s ${WARP10_VOLUME}/warp10/logs ${WARP10_HOME}/logs
  ln -s ${WARP10_VOLUME}/sensision/etc ${SENSISION_HOME}/etc
  ln -s ${WARP10_VOLUME}/sensision/data ${SENSISION_HOME}/data
  ln -s ${WARP10_VOLUME}/sensision/scripts ${SENSISION_HOME}/scripts
fi


# Launching Warp10
${WARP10_HOME}/bin/warp10-standalone.init start
echo "Warp10 running"

# Launching sensision
${SENSISION_HOME}/bin/sensision.init start
#echo "Sensision running"

# Launching SimpleHTTPServer
cd /opt/quantum/vulcanized
python -m SimpleHTTPServer 8081 &


echo "All process are running"
read
