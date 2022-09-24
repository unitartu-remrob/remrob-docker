#!/bin/bash
#this is to be called inside the container

repo=/home/$USER/repos
session_token=$GIT_PAT #it's a env variable passed to the container
answ="yes"
[ -d $repo ] && echo "Directory /path/to/dir exists. Are you sure you want to remove? yes|no" && read answ 
if [ "$answ" != "yes" ]
then
echo "Aborting."
exit 0
fi
curl --location --request GET "http://192.168.200.201/api/v1/reclone?token=$GIT_PAT&force=true"
echo ""
