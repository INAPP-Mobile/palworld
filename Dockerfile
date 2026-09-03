# Palworld Dedicated Server on Railway
# https://github.com/thijsvanloef/palworld-server-docker
# Wraps the official pinned image so we can:
#   1. Pin the exact Palworld version (no :latest drift)
#   2. Run as root so the Railway-managed volume at /palworld is writable
#      (the upstream image's `steam` user has no permission to chown
#      a root-owned fresh Railway volume; doing the chown as root first
#      then dropping to the steam user is the proven pattern)
#   3. Layer in a Railway-aware entrypoint that verifies the volume
#      before exec'ing the upstream binary
#   4. Expose the REST API on a known TCP port for Railway healthcheck
#      (Railway doesn't support UDP healthchecks, so we use the REST API
#      on port 8212 as an HTTP sidecar healthcheck)
FROM thijsvanloef/palworld-server-docker:v2.7.3

USER root

# Bake in our entrypoint. The image's stock entrypoint lives at
# /entrypoint.sh; we wrap it so we can guarantee /palworld is owned
# by the steam user (UID 1000) before the game tries to write saves.
COPY entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod +x /usr/local/bin/railway-entrypoint.sh

# The upstream image already sets PORT=8211 (UDP game port) and
# REST_API_PORT=8212 (TCP REST API). We keep those defaults.
# Railway injects PORT=8080 on services without an explicit PORT var,
# which would break the game port mapping. We explicitly set PORT=8211
# to prevent Railway from overriding it.
ENV PORT=8211
ENV REST_API_PORT=8212

# EXPOSE both the game port (UDP) and REST API (TCP for healthcheck)
EXPOSE 8211/udp
EXPOSE 8211/tcp
EXPOSE 8212/tcp

# Use our Railway-aware entrypoint
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
