#!/bin/bash
set -ex
# Copy key sang slave
if [ "$(hostname)" = "hadoop-master" ]; then

    # Master → Master
    sudo -u hadoop-22133012 ssh-copy-id -i /home/hadoop-22133012/.ssh/id_rsa.pub \
        -o StrictHostKeyChecking=no hadoop-22133012@hadoop-master

    # Master → Slave
    sudo -u hadoop-22133012 sshpass -p "dangha12042004" \
        ssh-copy-id -o StrictHostKeyChecking=no hadoop-22133012@hadoop-slave
fi