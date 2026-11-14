#!/bin/sh
echo DUMP_BEGIN
id; hostname; uname -a
echo TOOLS
which python3 curl wget nc openssl 2>/dev/null
python3 --version 2>/dev/null
echo ARP
cat /proc/net/arp
echo PYSCAN
python3 - << 'PY'
import socket, os, urllib.request
print("proxy", os.environ.get("HTTP_PROXY"), os.environ.get("HTTPS_PROXY"))
ports=[22,53,80,81,88,443,1080,3000,3128,3306,5000,5432,6379,8000,8080,8081,8443,8888,9000,9090,9200,2375,2376,2377,5984,11211,27017,6432,15432]
hosts=["172.21.0.1","172.21.0.2","172.21.0.3","172.21.0.4","172.21.0.5","172.21.0.6","172.21.0.7","172.21.0.8","127.0.0.1"]
for h in hosts:
    open_p=[]
    for p in ports:
        s=socket.socket(); s.settimeout(0.4)
        try:
            if s.connect_ex((h,p))==0:
                open_p.append(p)
        except Exception:
            pass
        finally:
            s.close()
    print("OPEN", h, open_p, flush=True)

def fetch(url, proxy=None, timeout=4):
    try:
        if proxy:
            handlers=[urllib.request.ProxyHandler({"http":proxy,"https":proxy})]
        else:
            handlers=[urllib.request.ProxyHandler({})]
        op=urllib.request.build_opener(*handlers)
        req=urllib.request.Request(url, headers={"User-Agent":"ctf"})
        with op.open(req, timeout=timeout) as r:
            b=r.read(400)
            print("HTTP", url, "via", proxy, r.status, b[:300], flush=True)
    except Exception as e:
        print("HTTPFAIL", url, "via", proxy, type(e).__name__, e, flush=True)

px="http://172.21.0.1:3128"
for url in [
    "http://172.21.0.1:3128/",
    "http://172.21.0.1/",
    "http://172.21.0.3/",
    "http://169.254.169.254/latest/meta-data/",
    "http://plugin-builder.btcpayserver.org/health",
    "http://172.21.0.1:8080/",
    "http://172.21.0.1:5000/",
]:
    fetch(url, None)
    fetch(url, px)
PY
echo DUMP_END
