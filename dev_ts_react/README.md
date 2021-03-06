# What is this.
Build typescript + react development environment with ssh.

# How to use

1. Run a docker image.
```
$ git clone https://github.com/liutoki/dockerfiles.git
$ cd dockerfiles/dev_ts_react
$ docker-compose up -d
```
2. Access to docker image from your host os
```
$ ssh -X -p 63205 root@localhost
# The password is ``screencast``.
```
3. Clean up
```
$ docker-compose stop
# If you want to remove docker-compose image, do the following command.
$ docker-compose rm
```

# Tips
## Access from vscode on windows+vagrant+linux+docker.
1. vagrant ssh config
```
$ vagrant ssh-config >> ~/.ssh/config
```
2. Add dev_ts_react ssh config
```
Host dev_ts_react
  HostName 127.0.0.1
  User root
  port 63205
  ProxyCommand C:\Windows\System32\OpenSSH\ssh.exe -W %h:%p vagrant
```
3. Change vscode setting
```
"remote.SSH.showLoginTerminal": true
```

# Memo
OS:debian
