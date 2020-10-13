FROM node:14.13.1-stretch
ENV LANG C.UTF-8

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y curl wget less lsof git

# WORKDIR
WORKDIR /usr/src/app

# typescript
# install typescript for global.
RUN npm install -g -y typescript

# install react for global.
RUN npm install -g react react-dom react-native-cli
RUN npm install -g @types/react @types/react-dom @types/react-native-cli

# SSH
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/#\?PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

# I use this docker file in serial console.
ENV DEBIAN_FRONTEND text

# .bashrc
RUN echo "if [ -f ~/.bashrc ]; then  . ~/.bashrc;  fi" >>~/.bash_profile
RUN echo "PATH=${PATH}" >> ~/.bashrc

