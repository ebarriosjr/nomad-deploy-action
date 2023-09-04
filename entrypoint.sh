#!/bin/sh

NOMAD_VERSION="1.6.1"

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
  curl https://releases.hashicorp.com/nomad/$NOMAD_VERSION/nomad_$NOMAD_VERSION.zip -o nomad.zip && \
  unzip nomad.zip && \
  mv nomad /usr/local/bin/ && \
  rm nomad.zip
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
