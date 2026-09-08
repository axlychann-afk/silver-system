FROM ubuntu:22.04

# Setting lingkungan agar tidak ada prompt interaktif saat instalasi
ENV DEBIAN_FRONTEND=noninteractive

# 1. Update dan install aplikasi yang dibutuhkan
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    wget \
    gnupg \
    lsb-release \
    iproute2 \
    && curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ jammy main" | tee /etc/apt/sources.list.d/cloudflare-client.list \
    && apt-get update && apt-get install -y cloudflare-warp \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Setup SSH
RUN mkdir -p /var/run/sshd
# Ganti 'passwordlu' dengan password yang kamu inginkan
RUN echo 'root:passwordlu' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 3. Optimasi koneksi biar tidak sering putus
RUN echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config && \
    echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config

EXPOSE 22

# 4. Perintah startup: Nyalakan WARP, tunggu, lalu nyalakan SSH
CMD bash -c "warp-svc & sleep 5 && warp-cli --accept-tos registration new && warp-cli --accept-tos connect && /usr/sbin/sshd -D"
