#!/bin/bash
# Bash script to set up a simple 3 replica set in mongodb via bash.
# Assumes node1, node2, and node3 are hosts on the network, which you can resolve.
# At this point in time this must be run on $node2 and $node3, prior to $node1.

# vars
node1=ubuntu-mongo1
node2=ubuntu-mongo2
node3=ubuntu-mongo3
replicationSetName=rs-savino
logPath=/root/$HOSTNAME
mongodport=27017

# update the system if necessary, get new packages lists
apt-get update -y > /dev/null 2>&1


# remove any existing mongodb
apt-get remove mongodb-org -y > /dev/null 2>&1
mv /etc/mongod.conf /etc/mongod.conf-backup > /dev/null 2>&1
rm -rf /data/$replicationSetName_$HOSTNAME > /dev/null 2>&1


# install the key responsible for signing the mongodb packages and load repository into sources.list.d for apt
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 > /dev/null 2>&1
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list 2>&1

# update once more to get mongodb packages list, install mongodb (and dep packages)
apt-get update -y > /dev/null 2>&1
apt-get install mongodb-org -y > /dev/null 2>&1

# stop or kill any running mongod post-install if applicable
service mongod stop > /dev/null 2>&1
pidof mongod | xargs kill > /dev/null 2>&1
sleep 2

# create a directory for the db to live
mkdir -p /data/$replicationSetName_$HOSTNAME

# someone somewhere said that you don't want the bindIp directive in the config ¯\_(ツ)_/¯
#sed -e '/bindIp/ s/^#*/#/' -i /etc/mongod.conf

# start mongod, set replica set name, log path, and db path. wait for 5 before continuing
mongod --replSet $replicationSetName --logpath "/root/$HOSTNAME" --dbpath /data/$replicationSetName_$HOSTNAME --fork

# connect to node1 and configure replica set
if [ "$HOSTNAME" = "$node1" ]; then
	echo "$node1 detected, waiting 5 to ensure mongod started, then adding replicas"
	sleep 5
	mongo --port $mongodport init-replica-set.js
