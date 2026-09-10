FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl wget nmap netcat-openbsd dnsutils \
      jq vim strace gdb iproute2 iputils-ping \
      python3 python3-pip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -sLO "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/

# Install CDK (Container exploit toolkit)
RUN curl -sLO "https://github.com/cdk-team/CDK/releases/download/v1.5.3/cdk_linux_amd64" && \
    chmod +x cdk_linux_amd64 && mv cdk_linux_amd64 /usr/local/bin/cdk || true

# Install peirates
RUN curl -sLO "https://github.com/inguardians/peirates/releases/latest/download/peirates-linux-amd64.tar.xz" && \
    tar -xf peirates-linux-amd64.tar.xz -C /usr/local/bin/ 2>/dev/null && \
    rm -f peirates-linux-amd64.tar.xz || true

COPY attack-chain.sh /opt/attack-chain.sh
RUN chmod +x /opt/attack-chain.sh

WORKDIR /opt
CMD ["sleep", "infinity"]
