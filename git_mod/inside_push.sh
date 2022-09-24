#!/bin/bash
#this is to be called inside the container

repo=/home/$USER/repos

# env
# @GIT_PAT

curl --location --request GET "http://192.168.200.201:5000/api/v1/commit_push?token=$GIT_PAT" # switch to remrob.ut.ee later
echo ""
