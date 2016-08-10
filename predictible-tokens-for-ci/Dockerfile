FROM warp10io/warp10:1.0.10

COPY ci.tokens ${WARP10_HOME}/etc/ci.tokens
RUN  sed s/"\#\ Launching\ Warp10"/"echo\ \"warp\.token\.file\ \=\ \${WARP10_HOME}\/etc\/ci\.tokens\"\ \>\>\ \${WARP10_VOLUME}\/warp10\/etc\/conf\-standalone\.conf"/ /opt/warp10/bin/warp10.start.sh -i 
#RUN echo "warp.token.file = ${WARP10_HOME}/etc/ci.tokens" >> ${WARP10_HOME}/etc/conf-standalone.conf
