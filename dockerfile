FROM ubuntu:20.04

# Install necessary packages
RUN apt update
RUN apt install software-properties-common -y
RUN add-apt-repository ppa:gluster/glusterfs-7
RUN apt update
RUN apt install glusterfs-server -y
# Create required directories
RUN mkdir -p /data /var/lib/glusterd /etc/glusterfs

# Expose GlusterFS ports
EXPOSE 24007 24008 49152

# Set entrypoint
CMD ["glusterd", "-N"]
#CMD ["tail", "-f", "/dev/null"]
