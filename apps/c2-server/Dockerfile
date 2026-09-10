# KOAD-S08: Simulated C2 (Command and Control) Server
# Receives heartbeats from "compromised" pods. Logs only — no real C2.
# DO NOT deploy in production environments.
FROM python:3.11-slim

WORKDIR /app
COPY server.py .

EXPOSE 4444
CMD ["python", "server.py"]
