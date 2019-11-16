FROM ubuntu:19.10

RUN apt update
RUN apt install -y curl wget gnupg less lsof net-tools git apt-utils

# Dart
# https://dart.dev/get-dart
RUN apt install apt-transport-https
RUN sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
RUN sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'

RUN apt update
RUN apt install -y dart

ENV PATH="${PATH}:/usr/lib/dart/bin/"
ENV PATH="${PATH}:/root/.pub-cache/bin"

RUN pub global activate webdev
RUN pub global activate stagehand

# Flutter
# https://flutter.dev/docs/get-started/install/linux
RUN apt install -y xz-utils
WORKDIR /tmp
RUN wget https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_v1.9.1+hotfix.6-stable.tar.xz
RUN tar xf flutter_linux_v1.9.1+hotfix.6-stable.tar.xz -C /user/local
ENV PATH="${PATH}:/usr/local/flutter/bin"
RUN flutter precache

# SSH
RUN apt install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 62301
CMD ["/usr/sbin/sshd", "-D"]