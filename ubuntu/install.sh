#!/bin/bash

# usage: install.sh server_url cert_file cert_password

# Ubuntu 16.x
# RavenDB 4.0 version 4.0.3-patch-40031

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# capture all args
args=("$@")

# exit if no args
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    exit 1
fi


# configuration
RAVENDB_DL_FILE="RavenDB-4.0.3-patch-40031-linux-x64.tar.bz2"
RAVENDB_DL="https://daily-builds.s3.amazonaws.com/$RAVENDB_DL_FILE"

RAVENDB_USER="ravendb"
RAVENDB_GROUP="ravendb"

RAVENDB_HOME_DIR="/home/ravendb"
RAVENDB_DATA_DIR="/home/ravendb/data"

RAVENDB_CONF_FILE="settings.json"
SERVER_URL=${args[0]}

CERT_FILE=${args[1]}
CERT_PASS=${args[2]}

# create ravendb user to run the service
useradd -s /usr/sbin/nologin $RAVENDB_USER $RAVENDB_GROUP

#create home directory
mkdir -v -p $RAVENDB_HOME_DIR
chmod -R 0755 $RAVENDB_HOME_DIR
chown -R $RAVENDB_USER:$RAVENDB_GROUP $RAVENDB_HOME_DIR

#create data directory
mkdir -v -p $RAVENDB_DATA_DIR
chmod -R 0700 $RAVENDB_DATA_DIR
chown -R $RAVENDB_USER:$RAVENDB_GROUP $RAVENDB_DATA_DIR

# switch to ravendb home directory
cd $RAVENDB_HOME_DIR

# download ravendb install package and uncompress it
wget $RAVENDB_DL 
tar xvf $RAVENDB_DL_FILE

# build the settings file
echo "Creating the settings.json file"

touch $RAVENDB_CONF_FILE
chmod -R 0600 $RAVENDB_CONF_FILE
chown -R $RAVENDB_USER:$RAVENDB_GROUP $RAVENDB_CONF_FILE


echo "{" >> $RAVENDB_CONF_FILE
echo "\t\"ServerUrl\"=\"$SERVER_URL\"" >> $RAVENDB_CONF_FILE
echo "\t\"Setup.Mode\"=\"None\"" >> $RAVENDB_CONF_FILE
echo "\t\"Setup.Mode\"=\"None\"" >> $RAVENDB_CONF_FILE
echo "}" >> $RAVENDB_CONF_FILE