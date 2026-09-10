# Hidden Layers Demo

This image demonstrates how secrets can leak through Docker layer caching.

## Attack

```bash
# Build the image
docker build -t koad/hidden-layers:latest .

# The final image looks clean
docker run --rm koad/hidden-layers:latest cat /tmp/stolen-creds.txt
# File not found — looks safe

# But the secret is in the builder layer
docker history koad/hidden-layers:latest
docker save koad/hidden-layers:latest | tar xf - -C /tmp/layers/
# Inspect intermediate layers to find stolen-creds.txt
```

## Defense

- Use multi-stage builds properly (never COPY secrets into the final stage)
- Scan images with `docker history` and tools like Dive
- Use `.dockerignore` to prevent accidental inclusion
