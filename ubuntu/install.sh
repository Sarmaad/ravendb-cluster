#!/bin/bash

# Ubuntu 16.x
# RavenDB 4.0 version 4.0.3-patch-40031

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# configuration
RAVENDB_DL = "https://daily-builds.s3.amazonaws.com/RavenDB-4.0.3-patch-40031-linux-x64.tar.bz2"

RAVENDB_USER = "ravendb"
RAVENDB_GROUP = "ravendb"

RAVENDB_HOME_DIR = "/home/ravendb"
RAVENDB_DATA_DIR = "/home/ravendb/data"

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

