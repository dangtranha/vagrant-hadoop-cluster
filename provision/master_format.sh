#!/bin/bash
set -ex

su - hadoop-22133012 <<'EOF'
    cd ~
    # Master → Master
    sshpass -p 'dangha12042004' ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no hadoop-master       
    
    # Master → Slave
    sshpass -p 'dangha12042004' ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no hadoop-slave

    #format namenode
    hadoop/bin/hdfs namenode -format
EOF