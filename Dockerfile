FROM registry.access.redhat.com/rhel7
ENV container docker

#RUN yum -y update; yum clean all

#RUN yum -y swap -- remove systemd-container systemd-container-libs -- install systemd systemd-libs dbus fsck.ext4

RUN curl http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm -o /opt/epel-release-7-9.noarch.rpm
RUN rpm -ivh /opt/epel-release-7-9.noarch.rpm

RUN systemctl mask dev-mqueue.mount dev-hugepages.mount \
    systemd-remount-fs.service sys-kernel-config.mount \
    sys-kernel-debug.mount sys-fs-fuse-connections.mount \
    display-manager.service graphical.target systemd-logind.service

RUN yum -y install openssh-server sudo openssh-clients
RUN sed -i 's/#PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN ssh-keygen -q -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa && \
    ssh-keygen -q -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa && \
    ssh-keygen -q -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519

RUN echo 'root:docker.io' | chpasswd
RUN systemctl enable sshd.service

RUN yum install -y initscripts \
        net-tools \
        nc \
        libselinux-utils \
        which \
        git \
        policycoreutils-python \
        unzip \
        cronie \
        tree

RUN yum clean all

RUN mkdir /apps && chmod 777 /apps

VOLUME [ "/sys/fs/cgroup" ]

VOLUME ["/run"]

EXPOSE 0-65535

ENV TERM=xterm

ENV TEST=test

CMD ["/usr/sbin/init"]
