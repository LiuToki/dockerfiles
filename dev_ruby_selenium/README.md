# What is this.
Build ruby's scraping development environment with ssh.

# How to use

1. Run a docker image.
```
$ git clone https://github.com/liutoki/dockerfiles.git
$ cd dockerfiles/dev_ruby_scraping
$ docker build . -t  dev_ruby_scraping
$ docker run -d -P -p 63201:22 --name ruby_scraping -it dev_ruby_scraping
```
2. Access to docker image from your host os
```
$ ssh -X -p 63201 root@localhost
# The password is ``screencast``.
```
3. Clean up
```
$ docker container stop ruby_scraping
$ docker container rm ruby_scraping
# If you want to remove dev_ruby_scraping image, do the following command.
$ docker image rm dev_ruby_scraping
```

# Tips
## Access from vscode on windows+vagrant+linux+docker.
1. vagrant ssh config
```
$ vagrant ssh-config >> ~/.ssh/config
```
2. Add dev_ruby_scraping ssh config
```
Host dev_ruby_scraping
  HostName 127.0.0.1
  User root
  port 63201
  ProxyCommand C:\Windows\System32\OpenSSH\ssh.exe -W %h:%p vagrant
```
3. Change vscode setting
```
"remote.SSH.showLoginTerminal": true
```