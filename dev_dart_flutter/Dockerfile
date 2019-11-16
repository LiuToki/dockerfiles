FROM ubuntu:19.10

RUN apt-get update
RUN apt-get install -y curl wget gnupg less lsof net-tools git apt-utils

# Dart
# https://dart.dev/get-dart
RUN apt-get install apt-transport-https
RUN sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
RUN sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'

RUN apt-get update
RUN apt-get install -y dart

ENV PATH="${PATH}:/usr/lib/dart/bin/"
ENV PATH="${PATH}:/root/.pub-cache/bin"

RUN pub global activate webdev
RUN pub global activate stagehand

# Flutter
# https://flutter.dev/docs/get-started/install/linux
RUN apt-get install -y xz-utils
WORKDIR /tmp
RUN wget https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_v1.9.1+hotfix.6-stable.tar.xz
RUN mkdir /works/development
WORKDIR /user/local
RUN tar xf /tmp/flutter_linux_v1.9.1+hotfix.6-stable.tar.xz
ENV PATH="${PATH}:/usr/local/flutter/bin"
RUN flutter precache