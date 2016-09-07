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
if [ "HOSTNAME" = $node1 ]; then
	echo "Have you prepared $node1 and $node2?"
	read ready
	if [ "$ready" = "y"]; then
		printf "Okay, let's begin"
	else
		exit 1
	fi
fi
 
# update the system if necessary, get new packages lists
echo "Updating the system and packages lists"
apt-get update -y > /dev/null 2>&1

# install the key responsible for signing the mongodb packages and load repository into sources.list.d for apt
echo "Installing mongodb package repository key and installing repository to our sources file"
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 > /dev/null 2>&1
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

# update once more to get mongodb packages list, install mongodb (and dep packages)
echo "Installing mongodb-org and dependencies"
apt-get update -y > /dev/null 2>&1
apt-get install mongodb-org -y > /dev/null 2>&1

# stop or kill any running mongod post-install if applicable
echo "Stop any potential mongod post-install"
service stop mongod
sleep 2

# create a directory for the db to live
echo "Creating the directory to house the database"
mkdir -p /data/$replicationSetName_$HOSTNAME

# someone somewhere said that you don't want the bindIp directive in the config ¯\_(ツ)_/¯
#sed -e '/bindIp/ s/^#*/#/' -i /etc/mongod.conf

# start mongod, set replica set name, log path, and db path. wait for 5 before continuing
echo "Starting up mongod!"
mongod --replSet $replicationSetName --logpath "/root/$HOSTNAME" --dbpath /data/$replicationSetName_$HOSTNAME --fork

# connect to node1 and configure replica set
if [ "$HOSTNAME" = "$node1" ]; then
	echo "I see you are $node1, waiting 5 to ensure mongod started, then adding replicas"
	sleep 5
	mongo --eval "printjson(rs.add('$node2'))"
	mongo --eval "printjson(rs.add('$node3'))"
fi
	




