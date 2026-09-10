# KOAD S35: Simulated Cryptominer Image
# Mimics XMRig behavior without actual mining
FROM busybox:1.36

COPY fake-miner.sh /usr/local/bin/xmrig
RUN chmod +x /usr/local/bin/xmrig

ENTRYPOINT ["/usr/local/bin/xmrig"]
