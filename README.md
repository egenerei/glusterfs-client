# 🗄️ GlusterFS Ubuntu Docker Image

![Docker](https://img.shields.io/badge/Docker-GlusterFS-blue?logo=docker)  
A lightweight **GlusterFS server** running on **Ubuntu 20.04**.

## 🚀 Features
- Pre-installed **GlusterFS v7**
- Exposes required ports (**24007, 24008, 49152**)
- Runs `glusterd` in the foreground

## 🛠️ How to Use

### 📥 Pull the Image
To pull the Docker image from Docker Hub, run:
```bash
docker pull egenerei6/glusterfs-ubuntu
```

### ▶️ Run a GlusterFS Server
To run the GlusterFS container, execute the following command:
```bash
docker run -d --name glusterfs \
  --privileged \
  -p 24007:24007 \
  -p 24008:24008 \
  -p 49152:49152 \
  -v /data:/data \
  egenerei6/glusterfs-ubuntu
```

### 🔗 Connect Multiple Nodes
To connect multiple GlusterFS nodes:

1. Start another GlusterFS container on the new node.
2. Probe the new node from an existing container:
```bash 
docker exec -it glusterfs gluster peer probe <new-node-ip>
```
3. Create a volume
```bash
docker exec -t gs1-server gluster volume create gv0 replica 2 <node-1-ip>:/data/brick1 <node-2-ip>:/data/brick1 force
```
4. Start the volume:
```bash
docker exec -it glusterfs gluster volume start gv0
```
### 📌 Exposed Ports
| Port  | Purpose                     |
|-------|-----------------------------|
| 24007 | GlusterFS Management        |
| 24008 | GlusterFS Communication     |
| 49152 | Dynamic GlusterFS Services  |

## 📄 Docker Compose Example
This section provides a Docker Compose file for setting up a GlusterFS cluster using two GlusterFS servers. The file includes the setup for an Ubuntu container and two GlusterFS servers.
### 🛠️ Docker Compose File
```yaml
services:
  ubuntu:
    image: ubuntu:latest
    container_name: ubuntu
    networks:
      local-net:
        ipv4_address: 192.168.3.102
    privileged: true
    tty: true

  gs1-server:
    image: egenerei6/glusterfs-ubuntu
    container_name: gs1-server
    volumes:
      - ./volumes/server1:/data
    privileged: true
    networks:
      local-net:
        ipv4_address: 192.168.3.100

  gs2-server:
    image: egenerei6/glusterfs-ubuntu
    container_name: gs2-server
    volumes:
      - ./volumes/server2:/data
    privileged: true
    networks:
      local-net:
        ipv4_address: 192.168.3.101

networks:
  local-net:
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.3.0/24
```
### 🔍 Explanation of the Configuration
#### ubuntu: A basic Ubuntu container to simulate a client or management node.

• Runs the latest Ubuntu image.  
• Connected to the local-net network with the IP 192.168.3.102.  
• Enabled privileged mode and tty for interactive shell use.  

#### gs1-server & gs2-server: Two GlusterFS server nodes.

• Each uses the egenerei6/glusterfs-ubuntu image.  
• Mounted data volumes for persistent storage (./volumes/server1 and ./volumes/server2).  
• Both containers are connected to the local-net network with the IPs 192.168.3.100 and 192.168.3.101.  
• privileged mode is enabled to avoid permissions issues.  
• local-net: A custom bridge network with a defined subnet (192.168.3.0/24) for communication between the containers.  

### 🔗 How to Use
1. Save the above Docker Compose configuration to a file named docker-compose.yml.
2. Save this script in the same directory, to automatize the connection of the servers, the creation/start of the volume and the connection of the client.
```bash
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
```
3. Execute the script.
4. Connect to the client using:
``` bash
docker exec -it ubuntu sh
```
5. Move to the directory /mnt (This is where the glusterfs vg0 colume has been mounted to)
6. nano package is installed in the client so you can try to write a file.
```bash
nano test.txt
```
7. After writing save using Ctrl+X 
8. Check your local directory.
