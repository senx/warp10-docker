
export TERM=xterm

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

  # change default parameters
  sed -i -e "s/127.0.0.1/0.0.0.0/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warp.timeunits = us/warp.timeunits = ns/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxops = 1000/warpscript.maxops = 10000000000/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxops.hard = 2000/warpscript.maxops.hard = 10000000000/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxbuckets = 1000000/warpscript.maxbuckets = 10000000/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxbuckets.hard = 100000/warpscript.maxbuckets.hard = 1000000000/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxdepth = 1000/warpscript.maxdepth  = 10000/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxdepth.hard = 1000/warpscript.maxdepth.hard = 1000000000/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxfetch = 100000/warpscript.maxfetch = 1000000000/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxfetch.hard = 1000000/warpscript.maxfetch.hard = 10000000000/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxgts = 100000/warpscript.maxgts = 1000000000/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxgts.hard = 100000/warpscript.maxgts.hard = 1000000000/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxloop = 5000/warpscript.maxloop = 10000000/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxloop.hard = 10000/warpscript.maxloop.hard = 100000000/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxrecursion = 16/warpscript.maxrecursion = 24/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxrecursion.hard = 32/warpscript.maxrecursion.hard = 10000000/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxsymbols = 64/warpscript.maxsymbols = 1024/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxsymbols.hard = 256/warpscript.maxsymbols.hard = 10000000/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxpixels = 1000000/warpscript.maxpixels = 10000000/g" ${WARP10_HOME}/etc/conf-standalone.conf
  sed -i -e "s/warpscript.maxpixels.hard = 1000000/warpscript.maxpixels.hard = 1000000000/g" ${WARP10_HOME}/etc/conf-standalone.conf
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
