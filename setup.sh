# Create user warp10
if [ "`which useradd`" = "" ]
then
  adduser -D -s -H -h ${WARP10_HOME} -s /bin/bash warp10
  adduser -D -s -H -h ${SENSISION_HOME} -s /bin/bash sensision
else
  useradd -d ${WARP10_HOME} -M -r warp10
  useradd -d ${SENSISION_HOME} -M -r sensision
fi

# WARP10 install
if [ ! -d ${WARP10_VOLUME}/warp10 ]
then
  echo "Install Warp10"
  ${WARP10_HOME}/bin/warp10-standalone.bootstrap
  mkdir -p ${WARP10_VOLUME}/warp10
  mv ${WARP10_HOME}/etc ${WARP10_VOLUME}/warp10/etc
  ln -s ${WARP10_VOLUME}/warp10/etc ${WARP10_HOME}/etc
  mv ${WARP10_HOME}/data ${WARP10_VOLUME}/warp10/data
  ln -s ${WARP10_VOLUME}/warp10/data ${WARP10_HOME}/data
  mv ${WARP10_HOME}/macros ${WARP10_VOLUME}/warp10/macros
  ln -s ${WARP10_VOLUME}/warp10/macros ${WARP10_HOME}/macros
  mv ${WARP10_HOME}/jars ${WARP10_VOLUME}/warp10/jars
  ln -s ${WARP10_VOLUME}/warp10/jars ${WARP10_HOME}/jars
  mv ${WARP10_HOME}/warpscripts ${WARP10_VOLUME}/warp10/warpscripts
  ln -s ${WARP10_VOLUME}/warp10/warpscripts ${WARP10_HOME}/warpscripts
  mv ${WARP10_HOME}/logs ${WARP10_VOLUME}/warp10/logs
  ln -s ${WARP10_VOLUME}/warp10/logs ${WARP10_HOME}/logs
else
  echo "Warp10 already installed"
  #clean
  rm -rf ${WARP10_HOME}/etc ${WARP10_HOME}/data ${WARP10_HOME}/macros ${WARP10_HOME}/warpscripts ${WARP10_HOME}/logs
  #link Warp10
  ln -s ${WARP10_VOLUME}/warp10/etc ${WARP10_HOME}/etc
  ln -s ${WARP10_VOLUME}/warp10/data ${WARP10_HOME}/data
  ln -s ${WARP10_VOLUME}/warp10/macros ${WARP10_HOME}/macros
  ln -s ${WARP10_VOLUME}/warp10/warpscripts ${WARP10_HOME}/warpscripts
  ln -s ${WARP10_VOLUME}/warp10/logs ${WARP10_HOME}/logs
fi

# Sensision install
if [ ! -d ${WARP10_VOLUME}/sensision ]
then
  echo "Install Sensision"
  ${SENSISION_HOME}/bin/sensision.bootstrap
  mkdir -p ${WARP10_VOLUME}/sensision
  mv ${SENSISION_HOME}/etc ${WARP10_VOLUME}/sensision/etc
  ln -s ${WARP10_VOLUME}/sensision/etc ${SENSISION_HOME}/etc
  mv ${SENSISION_HOME}/data ${WARP10_VOLUME}/sensision/data
  ln -s ${WARP10_VOLUME}/sensision/data ${SENSISION_HOME}/data
  mv ${SENSISION_HOME}/scripts ${WARP10_VOLUME}/sensision/scripts
  ln -s ${WARP10_VOLUME}/sensision/scripts ${SENSISION_HOME}/scripts

else
  echo "Sensision already installed"
  #clean
  rm -rf  ${SENSISION_HOME}/etc ${SENSISION_HOME}/data  ${SENSISION_HOME}/scripts
  # link sensision
  ln -s ${WARP10_VOLUME}/sensision/etc ${SENSISION_HOME}/etc
  ln -s ${WARP10_VOLUME}/sensision/data ${SENSISION_HOME}/data
  ln -s ${WARP10_VOLUME}/sensision/scripts ${SENSISION_HOME}/scripts
fi

# Apply user permissions
chown -R warp10:warp10 ${WARP10_VOLUME}
chown -R warp10:warp10 ${WARP10_HOME}
chown -R sensision:sensision ${WARP10_VOLUME}/sensision
chown -R sensision:sensision ${SENSISION_HOME}
