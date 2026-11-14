#!/bin/sh
echo DUMP_BEGIN
id
uname -a
hostname
pwd
ls -la
echo CAP
sed -n "1,40p" /proc/1/status
echo ENV1
tr "\0" "\n" < /proc/1/environ
echo SELF
tr "\0" "\n" < /proc/self/environ
echo SOCK
ls -la /var/run/docker.sock /run/docker.sock 2>&1
echo HOSTS
cat /etc/hosts
echo RESOLV
cat /etc/resolv.conf
echo ROUTE
cat /proc/net/route
echo TCP
cat /proc/net/tcp
echo MOUNTS
cat /proc/1/mounts
echo DUMP_END
