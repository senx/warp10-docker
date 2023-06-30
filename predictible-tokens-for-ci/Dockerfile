FROM warp10io/warp10:@WARP10_VERSION@-ubuntu

COPY --chown=warp10:warp10 ./ci.tokens /opt/warp10/etc/ci.tokens
RUN set eux; \
  mkdir /config.extra; \
  echo "warp.token.file=${WARP10_HOME}/etc/ci.tokens" > /config.extra/99-tokens-ci.conf; \
  chown -R warp10:warp10 /config.extra;
