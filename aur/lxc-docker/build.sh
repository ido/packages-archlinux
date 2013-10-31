#!/bin/env bash
sudo -u vagrant yaourt -Syu --noconfirm
cd /vagrant
sudo -u vagrant yaourt -S --noconfirm --needed rsync
sudo -u vagrant yaourt -S --noconfirm --needed aufs3
sudo -u vagrant yaourt -S --noconfirm --needed lxc bridge-utils
sudo -u vagrant makepkg -s
