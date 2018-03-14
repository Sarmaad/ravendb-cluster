#!/bin/bash
#usage: install.sh server_url cert_file cert_password
#Ubuntu 16.x
#RavenDB 4.0 version 4.0.3-patch-40031

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# capture all args
args=("$@")

# exit if no args
if [ $# -ne 3 ]; then
    echo "you must provide at least 3 arguments"
    echo "install.sh <ravendb dns> <cert file location> <cert file password>"
    exit 1
fi

# configuration
RAVENDB_DL_FILE="RavenDB-4.0.3-patch-40031-linux-x64.tar.bz2"
RAVENDB_DL="https://daily-builds.s3.amazonaws.com/$RAVENDB_DL_FILE"

RAVENDB_USER="ravendb"
RAVENDB_GROUP="ravendb"

RAVENDB_HOME_DIR="/home/ravendb"
RAVENDB_DATA_DIR="/home/ravendb/data"

SERVER_URL=${args[0]}

CERT_FILE=${args[1]}
CERT_PASS=${args[2]}

# export these variables for the purpose of templates
export RAVENDB_USER RAVENDB_HOME_DIR RAVENDB_DATA_DIR SERVER_URL CERT_FILE CERT_PASS

echo "installing required system packages"
apt-get -y --no-install-recommends install libunwind8 libicu55 libcurl3 ca-certificates

echo "create $RAVENDB_USER user "
groupadd $RAVENDB_GROUP
useradd -s /usr/sbin/nologin -g$RAVENDB_GROUP $RAVENDB_USER

echo "create home directory and set permissions"
mkdir -v -p $RAVENDB_HOME_DIR
chmod -R 0755 $RAVENDB_HOME_DIR
chown -R $RAVENDB_USER:$RAVENDB_GROUP $RAVENDB_HOME_DIR

echo "create data directory"
mkdir -v -p $RAVENDB_DATA_DIR
chmod -R 0700 $RAVENDB_DATA_DIR
chown -R $RAVENDB_USER:$RAVENDB_GROUP $RAVENDB_DATA_DIR

echo "download ravendb install package"
wget -q --show-progress -P $RAVENDB_HOME_DIR $RAVENDB_DL 
echo "uncompressing pachage in $RAVENDB_HOME_DIR"
tar -xf $RAVENDB_HOME_DIR/$RAVENDB_DL_FILE -C $RAVENDB_HOME_DIR
#remove downloaded package
rm -f $RAVENDB_HOME_DIR/$RAVENDB_DL_FILE
chown -R $RAVENDB_USER:$RAVENDB_GROUP $RAVENDB_HOME_DIR/RavenDB

echo "Creating the settings.json file (if not exists)"
cat ../settings.json.template | envsubst > $RAVENDB_HOME_DIR/settings.json
chmod -R 0600 $RAVENDB_HOME_DIR/settings.json
chown -R $RAVENDB_USER:$RAVENDB_GROUP $RAVENDB_HOME_DIR/settings.json

echo "Creating ravendb service file"
cat ../ravendb.service.template | envsubst > $RAVENDB_HOME_DIR/ravendb.service
chmod -R 0600 $RAVENDB_HOME_DIR/ravendb.service
chown -R $RAVENDB_USER:$RAVENDB_GROUP $RAVENDB_HOME_DIR/ravendb.service

echo "Copy settings.json to ravendb server directory"
cp $RAVENDB_HOME_DIR/settings.json $RAVENDB_HOME_DIR/RavenDB/Server/settings.json

echo "Install ravendb service in systemd"
systemctl enable $RAVENDB_HOME_DIR/ravendb.service

echo "------------------------"
echo "------------------------"
echo "Instalation Completed..."
echo "Test your server by running ravendb: $RAVENDB_HOME_DIR/RavenDB/Server/Raven.Server"
echo "You may start ravendb service using: systemctl start ravendb"
echo "------------------------"