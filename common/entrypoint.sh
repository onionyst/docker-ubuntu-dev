#!/bin/bash

username="ubuntu"
pubkey="$PUBKEY"

if [ ! -f "/home/$username/.ssh/authorized_keys" ]; then
  mkdir -p /home/$username/.ssh
  if [ -n "$pubkey" ]; then
    echo $pubkey >/home/$username/.ssh/authorized_keys
  fi
fi

sudo service ssh start
exec "$@"
