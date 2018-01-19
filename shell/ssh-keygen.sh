#!/bin/bash

test -d ~/.ssh || mkdir ~/.ssh
chmod 700 ~/.ssh
test -f ~/.ssh/authorized_keys || touch ~/.ssh/authorized_keys
ssh-keygen -t rsa -b 4096

echo "ssh-copy-id '-p 52113' -i ~/.ssh/id_rsa.pub <username>@<host>"

chmod 644 ~/.ssh/authorized_keys

# https://github.com/linuxsun
