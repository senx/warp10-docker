FROM warp10io/warp10:@WARP10_VERSION@-ubuntu

COPY --chown=warp10:warp10 ./ci.tokens ${WARP10_VOLUME}.bak/warp10/etc/ci.tokens
RUN set eux; \
  echo "warp.token.file=${WARP10_HOME}/etc/ci.tokens" > ${WARP10_VOLUME}.bak/warp10/etc/conf.d/99-tokens-ci.conf; \
  chown warp10:warp10 ${WARP10_VOLUME}.bak/warp10/etc/conf.d/99-tokens-ci.conf;
