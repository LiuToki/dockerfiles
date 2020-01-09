FROM ruby:2.6.5
ENV LANG C.UTF-8

ENV DEBIAN_FRONTEND noninteractive

RUN apt update
RUN apt install -y curl wget gnupg less lsof net-tools git apt-utils

# selenium-webdriver
RUN wget https://download-installer.cdn.mozilla.net/pub/firefox/releases/62.0/linux-x86_64/ja/firefox-65.0.tar.bz2
RUN tar xfj firefox-62.0.tar.bz2
RUN mv firefox /usr/local/
RUN ln -s /usr/local/firefox/firefox /usr/local/bin/firefox
RUN apt install libgtk-3-dev

# geckodriver
RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.26.0/geckodriver-v0.26.0-linux64.tar.gz
RUN tar xzvf geckodriver-v0.26.0-linux64.tar.gz
RUN mv geckodriver /usr/local/bin/

# xvfb
RUN apt install xvfb
RUN cat <<EOF > /etc/systemd/system/Xvfb.service \
[Unit] \
Description=X Virtual Frame Buffer Service \
After=network.target \
[Service] \
ExecStart=/usr/bin/Xvfb :5 -screen 0 1024x768x24 \
[Install] \
WantedBy=multi-user.target \
EOF

RUN chmod +x /etc/systemd/system/Xvfb.service
RUN systemctl daemon-reload
RUN systemctl enable Xvfb.service
RUN systemctl start Xvfb.service

ENV DISPLAY :5

# bundler
RUN gem install bundler

# SSH
RUN apt install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/#\?PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

# .bashrc
RUN echo "if [ -f ~/.bashrc ]; then  . ~/.bashrc;  fi" >>~/.bash_profile
RUN echo "PATH=${PATH}" >> ~/.bashrc

