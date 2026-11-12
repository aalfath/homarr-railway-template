# Homarr for Railway: the official image, pinned by version and digest, plus a small start script.
FROM ghcr.io/homarr-labs/homarr:v2.12.0@sha256:44c480afe9df57ce9de44cb664aec53199ea19926ebdd4e590c7b2c2c0a5ef79

COPY railway-start.sh /usr/local/bin/railway-start.sh
RUN chmod 755 /usr/local/bin/railway-start.sh

# Railway has no Docker socket, so Docker discovery stays off.
ENV ENABLE_DOCKER=false

# The start script moves nginx onto Railway's PORT, creates the admin user once,
# then hands over to the image's own entrypoint (/app/entrypoint.sh sh run.sh).
ENTRYPOINT ["bash", "/usr/local/bin/railway-start.sh"]
CMD []
