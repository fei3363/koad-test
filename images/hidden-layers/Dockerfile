# KOAD S20/S12: Hidden Layers Image
# Demonstrates hiding malicious content in intermediate Docker layers.
# The final image looks clean, but earlier layers contain secrets/tools.
FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends curl netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*
RUN echo "KOAD_DEMO_AWS_KEY=AKIAIOSFODNN7EXAMPLE" > /tmp/stolen-creds.txt
RUN echo "#!/bin/sh" > /tmp/reverse-shell.sh \
    && echo "echo '[KOAD DEMO] reverse shell placeholder'" >> /tmp/reverse-shell.sh \
    && chmod +x /tmp/reverse-shell.sh

FROM nginx:1.27-alpine
COPY --from=builder /tmp/reverse-shell.sh /docker-entrypoint.d/98-hidden.sh

# The stolen-creds.txt is NOT in the final image, but remains
# in the builder layer — retrievable with `docker history` or
# `docker save | tar xf` on the intermediate layer.
