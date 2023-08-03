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
  sudo apt-get update && sudo apt-get install -y nomad
fi

NOMAD_ADDR=$NOMAD_ADDR:$NOMAD_PORT nomad job run $VARS $GITHUB_WORKSPACE/$NOMAD_JOB | sed '/rolling back to job/h; ${p;x;/./Q3;Q0}'
RESULT="$?"

# check result of nomad job run
if [ "$RESULT" == "1" ]; then
    echo -e "nomad exit Code:" $RESULT "\n[ERROR] FAILED to deploy job"
    exit 1
elif [ "$RESULT" == "3" ]; then
    echo -e "nomad exit Code:" $RESULT "\n[ERROR] Job rolled back after failed deployment"
    exit 1
elif [ "$RESULT" == "2" ]; then
    echo -e "nomad exit Code:" $RESULT "\n[WARN] RESOURCE EXHAUSTION detected.\n[WARN] Please verify your job in the nomad UI"
    exit 0
else
    echo "SUCCESSFULL deploy nomad job"
    exit 0
fi
