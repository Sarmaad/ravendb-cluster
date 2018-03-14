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
    echo "eg: sudo ./install.sh db01.test.com /root/cert.pfx P@ssword123"
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

CERT_FILE_PATH=${args[1]}
CERT_FILE=$RAVENDB_HOME_DIR/$(basename $CERT_FILE_PATH)
CERT_PASS=${args[2]}

echo 
echo "installing required system packages"
apt-get -y --no-install-recommends install libunwind8 libicu55 libcurl3 ca-certificates

echo 
echo "create $RAVENDB_USER user "
groupadd $RAVENDB_GROUP
useradd -s /usr/sbin/nologin -g$RAVENDB_GROUP $RAVENDB_USER

echo
echo "create home directory and set permissions"
mkdir -v -p $RAVENDB_HOME_DIR
chmod -R 0755 $RAVENDB_HOME_DIR
chown -R $RAVENDB_USER:$RAVENDB_GROUP $RAVENDB_HOME_DIR

echo
echo "create data directory"
mkdir -v -p $RAVENDB_DATA_DIR
chmod -R 0700 $RAVENDB_DATA_DIR
chown -R $RAVENDB_USER:$RAVENDB_GROUP $RAVENDB_DATA_DIR

echo
echo "download ravendb install package"
wget -q --show-progress -P $RAVENDB_HOME_DIR $RAVENDB_DL 

echo
echo "uncompressing pachage in $RAVENDB_HOME_DIR"
tar -xf $RAVENDB_HOME_DIR/$RAVENDB_DL_FILE -C $RAVENDB_HOME_DIR
#remove downloaded package
rm -f $RAVENDB_HOME_DIR/$RAVENDB_DL_FILE
chown -R $RAVENDB_USER:$RAVENDB_GROUP $RAVENDB_HOME_DIR/RavenDB

echo
echo "copy certificate from $CERT_FILE_PATH to $CERT_FILE"
cp $CERT_FILE_PATH $CERT_FILE
chmod 0700 $CERT_FILE
chown $RAVENDB_USER:$RAVENDB_GROUP $CERT_FILE

# export these variables for the purpose of templates
export RAVENDB_USER RAVENDB_HOME_DIR RAVENDB_DATA_DIR SERVER_URL CERT_FILE CERT_PASS

echo
echo "Creating the settings.json file (if not exists)"
cat ../settings.json.template | envsubst > $RAVENDB_HOME_DIR/settings.json
chmod -R 0600 $RAVENDB_HOME_DIR/settings.json
chown -R $RAVENDB_USER:$RAVENDB_GROUP $RAVENDB_HOME_DIR/settings.json

echo
echo "Creating ravendb service file"
cat ../ravendb.service.template | envsubst > $RAVENDB_HOME_DIR/ravendb.service
chmod -R 0600 $RAVENDB_HOME_DIR/ravendb.service
chown -R $RAVENDB_USER:$RAVENDB_GROUP $RAVENDB_HOME_DIR/ravendb.service

echo
echo "Copy settings.json to ravendb server directory"
cp $RAVENDB_HOME_DIR/settings.json $RAVENDB_HOME_DIR/RavenDB/Server/settings.json

echo
echo "Install ravendb service in systemd"
systemctl enable $RAVENDB_HOME_DIR/ravendb.service

#service port must be above 1024, anything below this port will require root user. 
#ref: https://serverfault.com/questions/112795/how-to-run-a-server-on-port-80-as-a-normal-user-on-linux
echo 
echo "--------------------------------------------------------------------------------------------------"
echo "Instalation Completed..."
echo "--------------------------------------------------------------------------------------------------"
echo "NOTES:"
echo "make sure you have added your DNS to hosts with the public IP address before starting the service."
echo "you can watch the logs using: tail -f /var/log/syslog"
echo "the service will run under user: $RAVENDB_USER"
echo "You may start ravendb service using: systemctl start ravendb"
echo "--------------------------------------------------------------------------------------------------"