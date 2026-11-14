#!/bin/sh
# IPs only; no DUMP_BEGIN; no environ; no /dev/tcp; --noproxy bypasses squid
echo PROBE_START
for h in 172.21.0.1 172.21.0.3 172.21.0.4 172.21.0.5 172.21.0.6 172.21.0.7 172.21.0.8 172.21.0.9; do
  for p in 80 443 3128 5432 8080 2375 5000; do
    out=$(curl --noproxy '*' -sS -m 2 -D - -o /tmp/pb.body "http://$h:$p/" 2>&1 | head -c 350)
    code=$?
    if [ "$code" -eq 0 ] || echo "$out" | grep -qiE 'HTTP/|postgres|Npgsql|nginx|ASP.NET'; then
      echo "HIT $h $p rc=$code"
      echo "$out"
      echo BODY; head -c 180 /tmp/pb.body 2>/dev/null; echo
    else
      echo "MISS $h $p rc=$code"
    fi
  done
done
echo PROBE_END
