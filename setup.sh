# Create user warp10
if [ "`which useradd`" = "" ]
then
  adduser -D -s -H -h ${WARP10_HOME} -s /bin/bash warp10
  adduser -D -s -H -h ${SENSISION_HOME} -s /bin/bash sensision
else
  useradd -d ${WARP10_HOME} -M -r warp10
  useradd -d ${SENSISION_HOME} -M -r sensision
fi

# WARP10 - install and manage upgrade
if [ ! -d ${WARP10_VOLUME}/warp10 ]
then
  echo "Install Warp10"
  # Stop/start to init config
  ${WARP10_HOME}/bin/warp10-standalone.init start && ${WARP10_HOME}/bin/warp10-standalone.init stop
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
if [ ! -d ${WARP10_VOLUME}/sensision ]
then
  echo "Install Sensision"
  ${SENSISION_HOME}/bin/sensision.bootstrap
  mkdir -p ${WARP10_VOLUME}/sensision/data
  mv ${SENSISION_HOME}/etc ${WARP10_VOLUME}/sensision/etc
  ln -s ${WARP10_VOLUME}/sensision/etc ${SENSISION_HOME}/etc
  ln -s ${WARP10_VOLUME}/sensision/data ${SENSISION_HOME}/data
  mv ${SENSISION_HOME}/scripts ${WARP10_VOLUME}/sensision/scripts
  ln -s ${WARP10_VOLUME}/sensision/scripts ${SENSISION_HOME}/scripts
else
  echo "Sensision already installed"
  #clean
  rm -rf  ${SENSISION_HOME}/etc ${SENSISION_HOME}/scripts
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