#!/bin/bash
# Bash script to set up a simple 3 replica set in mongodb via bash.
# Assumes node1, node2, and node3 are hosts on the network, which you can resolve.
# Also assumes that you have installed mongodb-org on node2 and node3 prior to running.

# vars
node1=ubuntu-mongo1
node2=ubuntu-mongo2
node3=ubuntu-mongo3
replicationSetName=rs-savino
logPath=/root/$HOSTNAME

# prompt user (config management please?)
echo "Have you prepared $node1 and $node2?"
read ready
if [ "$ready" = "y"]; then
	printf "Okay, let's begin"
else
	exit 1
fi
 
# update the system if necessary, get new packages lists
apt-get update -y

# install the key responsible for signing the mongodb packages and load repository into sources.list.d for apt
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

# update once more to get mongodb packages list, install mongodb (and dep packages)
apt-get update -y
apt-get install mongodb-org -y

# stop or kill any running mongod post-install if applicable
service stop mongod
sleep 2
pkill mongo

# create a directory for the db to live
mkdir -p /data/$replicationSetName_$HOSTNAME

# someone somewhere said that you don't want the bindIp directive in the config ¯\_(ツ)_/¯
#sed -e '/bindIp/ s/^#*/#/' -i /etc/mongod.conf

# start mongod, set replica set name, log path, and db path. wait for 5 before continuing
mongod --replSet $replicationSetName --logpath "/root/$HOSTNAME" --dbpath /data/$replicationSetName_$HOSTNAME --fork
sleep 5

# connect to node1 and configure replica set
if [ "$HOSTNAME" = "$node1" ]; then
	mongo --eval "printjson(rs.add('$node2'))"
	mongo --eval "printjson(rs.add('$node3'))"
fi
	




