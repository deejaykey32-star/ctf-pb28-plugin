#!/bin/sh
echo DUMP_BEGIN
id; hostname; uname -a
echo TOOLS
command -v python3; command -v curl; command -v wget; command -v bash; command -v nc
echo BASHSCAN
bash << 'BASH'
for h in 172.21.0.1 172.21.0.2 172.21.0.3 172.21.0.4 172.21.0.5 172.21.0.6 127.0.0.1; do
  for p in 22 53 80 443 1080 3000 3128 3306 5000 5432 6379 8000 8080 8443 8888 9000 2375 2376 27017; do
    (echo >/dev/tcp/$h/$p) >/dev/null 2>&1 && echo OPEN $h $p
  done
done
BASH
echo CURLSCAN
if command -v curl >/dev/null 2>&1; then
  for u in http://172.21.0.1:3128/ http://172.21.0.1/ http://172.21.0.3/ http://172.21.0.4/ http://169.254.169.254/latest/meta-data/ http://plugin-builder.btcpayserver.org/health; do
    echo CURL $u
    curl -sS -m 3 -D - -o /tmp/c.body "$u" | head -20
    echo BODY; head -c 200 /tmp/c.body 2>/dev/null; echo
  done
fi
echo PYSCAN
python3 - << 'PY' || echo NO_PYTHON
import socket, os, urllib.request
print("proxy", os.environ.get("HTTP_PROXY"))
ports=[22,80,443,3128,5432,6379,8080,2375,5000,9000]
hosts=["172.21.0.1","172.21.0.3","172.21.0.4","172.21.0.5","127.0.0.1"]
for h in hosts:
    open_p=[]
    for p in ports:
        s=socket.socket(); s.settimeout(0.4)
        try:
            if s.connect_ex((h,p))==0: open_p.append(p)
        except Exception:
            pass
        finally:
            s.close()
    print("OPEN", h, open_p, flush=True)
def fetch(url, proxy=None):
    try:
        h=[urllib.request.ProxyHandler({"http":proxy,"https":proxy} if proxy else {})]
        op=urllib.request.build_opener(*h)
        with op.open(urllib.request.Request(url, headers={"User-Agent":"ctf"}), timeout=4) as r:
            print("HTTP", url, "via", proxy, r.status, r.read(200), flush=True)
    except Exception as e:
        print("HTTPFAIL", url, "via", proxy, type(e).__name__, e, flush=True)
px="http://172.21.0.1:3128"
for url in ["http://172.21.0.1:3128/","http://172.21.0.1/","http://plugin-builder.btcpayserver.org/health"]:
    fetch(url, None); fetch(url, px)
PY
echo DUMP_END
