# Create user warp10
if [ "`which useradd`" = "" ]; then
  adduser -D -s -H -h ${WARP10_HOME} -s /bin/bash warp10
  adduser -D -s -H -h ${SENSISION_HOME} -s /bin/bash sensision
  addgroup sensision warp10
else
  useradd -d ${WARP10_HOME} -M -r warp10
  useradd -d ${SENSISION_HOME} -M -r sensision -G warp10
fi

# WARP10 - install and manage upgrade
if [ ! -d ${WARP10_VOLUME}/warp10 ]; then
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

# REPLACE HARD LINKS
sed -i "s/^standalone\.home.*/standalone\.home = \/opt\/warp10/" ${WARP10_CONF}
sed -i "s/^LEVELDB\_HOME=.*/LEVELDB\_HOME=\/opt\/warp10\/leveldb/" ${WARP10_HOME}/bin/snapshot.sh

sed -i "s/warpLog\.File=.*/warpLog\.File=\/opt\/warp10\/logs\/warp10\.log/" ${WARP10_HOME}/etc/log4j.properties
sed -i "s/warpscriptLog\.File=.*/warpscriptLog\.File=\/opt\/warp10\/logs\/warpscript.out/" ${WARP10_HOME}/etc/log4j.properties

# Sensision install
if [ ! -d ${WARP10_VOLUME}/sensision ]; then
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

# REPLACE HARD LINKS
sed -i "s/^sensision\.home.*/sensision\.home = \/opt\/sensision/" ${SENSISION_HOME}/etc/sensision.conf
sed -i "s/^sensision\.scriptrunner\.root.*/sensision\.scriptrunner\.root = \/opt\/sensision\/scripts/" ${SENSISION_HOME}/etc/sensision.conf
sed -i "s/sensisionLog\.File=.*/sensisionLog\.File=\/opt\/sensision\/logs\/nohup.out/" ${SENSISION_HOME}/etc/log4j.properties
