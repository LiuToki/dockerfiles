# What is this.
Build treefrog's development environment with ssh.

# How to use

1. Run a docker image.
```
$ git clone https://github.com/liutoki/dockerfiles.git
$ cd dockerfiles/dev_treefrog
$ docker-compose up -d
```
2. Access to docker image from your host os
```
$ ssh -X -p 63204 root@localhost
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
2. Add dev_treefrog ssh config
```
Host dev_treefrog
  HostName 127.0.0.1
  User root
  port 63204
  ProxyCommand C:\Windows\System32\OpenSSH\ssh.exe -W %h:%p vagrant
```
3. Change vscode setting
```
"remote.SSH.showLoginTerminal": true
```

## Access to app from Host.
1. Run the treefrog app.
```
$ treefrog -p 8800 /[path to treefrog root dir]
```
2. ssh port forwarding from Host.
```
ssh -L 8800:localhost:8800 dev_treefrog
```

3. Access through browser
````
http://localhost:8800
````