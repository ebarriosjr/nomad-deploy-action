#!/bin/sh

NOMAD_VERSION="1.6.1"

if [ -z "$NOMAD_JOB" ];
then
  echo "NOMAD_JOB variable requiered."
  exit 2
fi

if [ -z "$NOMAD_ADDR" ];
then
  echo -e "NOMAD_ADDR variable not set.\nUsing default value: http://127.0.0.1"
  NOMAD_ADDR = "http://127.0.0.1"
fi

if [ -z "$NOMAD_PORT" ];
then
  echo -e "NOMAD_PORT variable not set.\nUsing default value: 4646"
  NOMAD_PORT = "4646"
fi

if ! command -v nomad &> /dev/null
then
  echo -e "Installing nomad..."
  curl -sS https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip && \
  unzip -qq nomad.zip && \
  mv nomad /usr/local/bin/ && \
  rm nomad.zip
  echo -e "Installed Nomad version:" $(NOMAD_VERSION)
fi

echo -e "NOMAD_ADDR:" $NOMAD_ADDR "\nNOMAD_PORT:" $NOMAD_PORT "\nNOMAD_JOB:" $NOMAD_JOB""
NOMAD_ADDR=${NOMAD_ADDR}:${NOMAD_PORT} nomad job run $VARS $GITHUB_WORKSPACE/$NOMAD_JOB
RESULT="$?"

# check if job was rolled back
if [ "$RESULT" == "0" ]; then
    NOMAD_ROLLBACK=$(echo "${NOMAD_RESULT}" | sed '/rolling back to job/h; ${p;x;/./Q3;Q0}')
    RESULT="$?"
fi

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
