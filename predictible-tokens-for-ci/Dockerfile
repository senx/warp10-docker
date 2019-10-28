FROM warp10io/warp10

COPY ci.tokens ${WARP10_HOME}/etc/ci.tokens
RUN sed '/echo "Launch Warp/a echo "warp.token.file=${WARP10_HOME}/etc/ci.tokens" > ${WARP10_HOME}/etc/conf.d/90-tokens-ci.conf' /opt/warp10/bin/warp10.start.sh -i
