FROM tokyor/rstudio

ENV DEBIAN_FRONTEND noninteractive

# R
RUN R -e "install.packages(c('shiny', 'shinythemes', 'shinydashboard'), repos='http://cran.rstudio.com/')" 

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
CMD ["/usr/sbin/sshd", "-D"]

# .bashrc
RUN echo "if [ -f ~/.bashrc ]; then  . ~/.bashrc;  fi" >>~/.bash_profile
RUN echo "PATH=${PATH}" >> ~/.bashrc
