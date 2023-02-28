#!/bin/sh
if [ -z "$NOMAD_JOB" ];
then
  echo "NOMAD_JOB variable requiered."
  exit 2
fi

if [ -z "$NOMAD_ADDR" ];
then
  NOMAD_ADDR = "http://127.0.0.1"
fi

if [ -z "$NOMAD_PORT" ];
then
  NOMAD_PORT = "4646"
fi

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

echo "Vars: $VARS"
echo "Nomad Job: $GITHUB_WORKSPACE/$NOMAD_JOB"

NOMAD_ADDR=$NOMAD_ADDR:$NOMAD_PORT nomad job run $VARS -preserve-counts $GITHUB_WORKSPACE/$NOMAD_JOB
