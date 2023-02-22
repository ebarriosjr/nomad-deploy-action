#!/bin/sh

if ! command -v nomad &> /dev/null
then
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - && \
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
  sudo apt-get update && sudo apt-get install nomad
fi

# VARS should be a list of var_name=value
VARS=""
for i in $VARIABLES
do
	VARS+=" -var=\"$i\" "
done

ls $GITHUB_WORKSPACE

nomad job run $VARS "$GITHUB_WORKSPACE/$NOMAD_JOB"
