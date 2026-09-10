# KOAD S22: Masquerade Image
# Looks like kube-proxy but is actually a data exfiltrator (SIMULATED)
FROM busybox:1.36

LABEL io.kubernetes.container.name="kube-proxy"
LABEL maintainer="kubernetes@kubernetes.io"

COPY fake-kube-proxy.sh /usr/local/bin/kube-proxy
RUN chmod +x /usr/local/bin/kube-proxy

ENTRYPOINT ["/usr/local/bin/kube-proxy"]
