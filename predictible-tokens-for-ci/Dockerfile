FROM warp10io/warp10

COPY ci.tokens ${WARP10_HOME}/etc/ci.tokens
RUN echo "warp.token.file=${WARP10_HOME}/etc/ci.tokens" > ${WARP10_HOME}/etc/conf.d/99-tokens-ci.conf
