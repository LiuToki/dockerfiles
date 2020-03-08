FROM rocker/shiny

ENV DEBIAN_FRONTEND noninteractive

# tidyverse
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  libxml2-dev \
  libcairo2-dev \
  libsqlite-dev \
  libmariadbd-dev \
  libmariadbclient-dev \
  libpq-dev \
  libssh2-1-dev \
  unixodbc-dev \
  libsasl2-dev \
  && install2.r --error \
    --deps TRUE \
    tidyverse \
    dplyr \
    devtools \
    formatR \
    remotes \
    selectr \
    caTools \
    BiocManager

# rstudio for jp
# Change environment to Japanese(Character and DateTime)
ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
RUN sed -i '$d' /etc/locale.gen \
  && echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen ja_JP.UTF-8 \
	&& /usr/sbin/update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
RUN /bin/bash -c "source /etc/default/locale"
RUN ln -sf  /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# Install ipaexfont
RUN apt-get update && apt-get install -y \
  fonts-ipaexfont

# Install packages
RUN Rscript -e "install.packages(c('githubinstall', 'ranger'))"
RUN R -e "install.packages(c('shiny', 'shinythemes', 'shinydashboard', 'rmarkdown'), repos='http://cran.rstudio.com/')"

RUN apt-get update

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

# startup for all command
RUN echo "/init; /usr/sbin/sshd -D; /usr/bin/shiny-server.sh" >>~/.startup.sh
RUN chmod 744 ~/.startup.sh
CMD ["~/.startup.sh"]

# .bashrc
RUN echo "if [ -f ~/.bashrc ]; then  . ~/.bashrc;  fi" >>~/.bash_profile
RUN echo "PATH=${PATH}" >> ~/.bashrc
