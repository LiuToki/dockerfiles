FROM ubuntu:19.10

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt update
RUN apt install -y make cmake

# C++
RUN apt install -y wget gcc-c++
RUN apt install -y glibc-devel gmp-devel mpfr-devel libmpc-devel

RUN wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-9.2.0/gcc-9.2.0.tar.gz
RUN tar xzvf gcc-9.2.0.tar.gz
RUN cd gcc-9.2.0
RUN ./contrib/download_prerequisites

RUN mkdir build
RUN cd build
RUN ../configure --prefix=/usr  --program-suffix=-9.2.0 --enable-languages=c,c++ --disable-multilib
RUN export LD_LIBRARY_PATH=/usr/local/gcc-9.2.0/lib:$LD_LIBRARY_PATH
RUN export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu
RUN export C_INCLUDE_PATH=/usr/include/x86_64-linux-gnu
RUN export CPLUS_INCLUDE_PATH=/usr/include/x86_64-linux-gnu
RUN make -j 4
RUN make install

RUN cd ../../
RUN rm -f gcc-9.2.0.tar.gz
RUN rm -rf gcc-9.2.0

RUN apt remove -y gcc gcc-c++
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9.2.0 1 --slave   /usr/bin/g++ g++ /usr/local/bin/g++-9.2.0

# Qt
RUN apt install -y\
        tzdata \
        coreutils \
        qt5-default \
        qt5-qmake \
        qtbase5-dev \
        qtdeclarative5-dev \
        qtbase5-dev-tools \
        libqt5sql5-mysql \
        libqt5sql5-psql \
        libqt5sql5-odbc \
        libqt5sql5-sqlite \
        libqt5core5a \
        libqt5qml5 \
        libqt5xml5 \
        libpq5 \
        libodbc1 \
        libmongoc-dev \
        libbson-dev; \
    rm -rf /var/lib/apt/lists/*

# TreeFrog
WORKDIR /usr/src/treefrog
RUN curl -sL https://github.com/treefrogframework/treefrog-framework/archive/master.tar.gz | tar xz && \
    cd treefrog-framework-master && \
    ./configure --enable-shared-mongoc && \
    make -j"$(nproc)" -C src && \
    make -C src install && \
    make -j"$(nproc)" -C tools && \
    make -C tools install && \
    rm -rf /usr/src/treefrog

VOLUME  /webapp
WORKDIR /webapp
EXPOSE  8800
CMD ["treefrog", "-p", "8800", "/webapp"]

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

