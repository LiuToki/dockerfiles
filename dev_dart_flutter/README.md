# What is this.
Build dart's development environment with ssh.

# How to use

1. Run a docker image.
```
$ git clone https://github.com/liutoki/dockerfiles.git
$ cd dockerfiles/dev_dart_flutter
$ docker build . -t  dev_dart_flutter
$ docker run -d -P -p 63201:22 --name dart_flutter -it dev_dart_flutter
```
2. Access to docker image from your host os
```
$ ssh -X -p 63201 root@localhost
# The password is ``screencast``.
```
3. Clean up
```
$ docker container stop dart_flutter
$ docker container rm dart_flutter
# If you want to remove dev_dart_flutter image, do the following command.
$ docker image rm dev_dart_flutter
```

# Tips
## Access from vscode on windows+vagrant+linux+docker.
1. vagrant ssh config
```
$ vagrant ssh-config >> ~/.ssh/config
```
2. Add dev_dart_flutter ssh config
```
Host dev_dart_flutter
  HostName 127.0.0.1
  User root
  port 63201
  ProxyCommand C:\Windows\System32\OpenSSH\ssh.exe -W %h:%p vagrant
```
3. Change vscode setting
```
"remote.SSH.showLoginTerminal": true
```