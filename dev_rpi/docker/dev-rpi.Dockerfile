FROM ubuntu:24.04

ARG UID=1000
ARG GID=1000
ARG TZ=Asia/Tokyo
ARG DEV_PASSWORD=devpassword

ENV DEBIAN_FRONTEND=noninteractive

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo "${TZ}" > /etc/timezone

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    ninja-build \
    git \
    pkg-config \
    rsync \
    openssh-client \
    openssh-server \
    gdb-multiarch \
    qemu-user-static \
    binfmt-support \
    ca-certificates \
    curl \
    file \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
 && rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${GID} dev && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash dev && \
    echo "dev:${DEV_PASSWORD}" | chpasswd

RUN mkdir -p /var/run/sshd /home/dev/.ssh /opt/rpi-sysroot /workspace && \
    chown -R dev:dev /home/dev /workspace && \
    chmod 700 /home/dev/.ssh

RUN sed -ri 's/^#?PasswordAuthentication\s+.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -ri 's/^#?PubkeyAuthentication\s+.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -ri 's@session\s+required\s+pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

ENV RPI_SYSROOT_BASE=/opt/rpi-sysroot
ENV RPI_TARGET_TRIPLE=aarch64-linux-gnu
ENV RPI_CPU=

RUN cat >/etc/profile.d/rpi-dev-env.sh <<'EOF'
export RPI_SYSROOT_BASE="${RPI_SYSROOT_BASE:-/opt/rpi-sysroot}"
export RPI_TARGET_TRIPLE="${RPI_TARGET_TRIPLE:-aarch64-linux-gnu}"
export RPI_CPU="${RPI_CPU:-}"
export RPI_SYSROOT="${RPI_SYSROOT_BASE}/${RPI_TARGET_TRIPLE}"

export PKG_CONFIG_DIR=
export PKG_CONFIG_SYSROOT_DIR="${RPI_SYSROOT}"
export PKG_CONFIG_LIBDIR="${RPI_SYSROOT}/usr/lib/${RPI_TARGET_TRIPLE}/pkgconfig:${RPI_SYSROOT}/usr/lib/pkgconfig:${RPI_SYSROOT}/usr/share/pkgconfig:${RPI_SYSROOT}/usr/local/lib/${RPI_TARGET_TRIPLE}/pkgconfig:${RPI_SYSROOT}/usr/local/lib/pkgconfig"
EOF

RUN chmod 644 /etc/profile.d/rpi-dev-env.sh && \
    echo 'source /etc/profile.d/rpi-dev-env.sh' >> /home/dev/.bashrc && \
    chown dev:dev /home/dev/.bashrc

COPY docker/entrypoint-sshd.sh /usr/local/bin/entrypoint-sshd.sh
RUN chmod +x /usr/local/bin/entrypoint-sshd.sh

WORKDIR /workspace

EXPOSE 22

ENTRYPOINT ["/usr/local/bin/entrypoint-sshd.sh"]
CMD ["/usr/sbin/sshd", "-D"]