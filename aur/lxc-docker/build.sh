#!/bin/env bash

sudo -u vagrant yaourt -Syu --noconfirm
sudo -u vagrant yaourt -S --noconfirm --needed rsync aufs3 bridge-utils lxc

cd /vagrant
sudo -u vagrant makepkg -s
