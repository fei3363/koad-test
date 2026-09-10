FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      hydra curl nmap netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /wordlists && \
    echo -e "admin\npassword\n123456\nP@ssw0rd\nkubernetes\nk8s-admin\nletmein\nroot\ntest\ndefault" > /wordlists/common.txt && \
    echo -e "eyJhbGciOiJSUzI1NiIsImtpZCI6ImZha2UifQ\ndefault-token-abc123\nadmin-token-xyz789" > /wordlists/tokens.txt

WORKDIR /wordlists
CMD ["sleep", "infinity"]
