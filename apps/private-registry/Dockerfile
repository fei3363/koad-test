# KOAD-S12/S20: Insecure Private Registry
# No authentication, delete enabled — simulates a poorly configured registry
# DO NOT deploy in production environments.
FROM registry:2

ENV REGISTRY_STORAGE_DELETE_ENABLED=true
ENV REGISTRY_HTTP_HEADERS_Access-Control-Allow-Origin='["*"]'

EXPOSE 5000
