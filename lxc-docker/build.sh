#!/bin/env bash
sudo -u vagrant yaourt -Syu --noconfirm
cd /vagrant
sudo -u vagrant yaourt -S --noconfirm rsync
sudo -u vagrant yaourt -S --noconfirm aufs3
sudo -u vagrant yaourt -S --noconfirm lxc bridge-utils
sudo -u vagrant makepkg -s
