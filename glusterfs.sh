#! /bin/bash
export IP_GS1="192.168.3.100"
export IP_GS2="192.168.3.101"

docker compose up -d 
docker exec -t gs1-server gluster peer probe $IP_GS1
docker exec -t gs1-server gluster peer probe $IP_GS2
docker exec -t gs1-server gluster volume create gv0 replica 2 $IP_GS1:/data/brick1 $IP_GS2:/data/brick1 force
docker exec -t gs1-server gluster volume start gv0

docker exec -t ubuntu ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
docker exec -t ubuntu dpkg-reconfigure -f noninteractive tzdata
docker exec -t ubuntu apt update
docker exec -t ubuntu apt install nano glusterfs-client -y -f
docker exec -t ubuntu mount -t glusterfs $IP_GS1:/gv0 /mnt
docker exec -t ubuntu chmod 777 -R /mnt