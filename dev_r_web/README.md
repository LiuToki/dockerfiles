# What is this.
Build r web development environment with ssh.

# How to use

1. Run a docker image.
```
$ git clone https://github.com/liutoki/dockerfiles.git
$ cd dockerfiles/dev_r_web
$ docker build . -t  dev_r_web
$ docker run -d -P -p 63203:22 --name dart_flutter -it dev_r_web
```
2. Access to docker image from your host os
```
$ ssh -X -p 63203 root@localhost
# The password is ``screencast``.
```
3. Clean up
```
$ docker container stop dart_flutter
$ docker container rm dart_flutter
# If you want to remove dev_r_web image, do the following command.
$ docker image rm dev_r_web
```

# Tips
## Access from vscode on windows+vagrant+linux+docker.
1. vagrant ssh config
```
$ vagrant ssh-config >> ~/.ssh/config
```
2. Add dev_r_web ssh config
```
Host dev_r_web
  HostName 127.0.0.1
  User root
  port 63203
  ProxyCommand C:\Windows\System32\OpenSSH\ssh.exe -W %h:%p vagrant
```
3. Change vscode setting
```
"remote.SSH.showLoginTerminal": true
```

# Memo
OS:debian
