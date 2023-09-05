#!/bin/sh

NOMAD_VERSION="1.6.1"

if [ -z "$NOMAD_JOB" ];
then
  if [ -z "$NOMAD_JOB_NAME" ];
  then
    echo "NOMAD_JOB or NOMAD_JOB_NAME variable requiered."
    exit 2
  else
    NOMAD_JOB=$NOMAD_JOB_NAME
  fi
fi

if [ -z "$NOMAD_ADDR" ];
then
  echo -e "NOMAD_ADDR variable not set.\nUsing default value: http://127.0.0.1"
  NOMAD_ADDR="http://127.0.0.1"
fi

if [ -z "$NOMAD_PORT" ];
then
  echo -e "NOMAD_PORT variable not set.\nUsing default value: 4646"
  NOMAD_PORT="4646"
fi

if [ -z "$NOMAD_ACTION" ];
then
  echo -e "NOMAD_ACTION variable not set.\nUsing default value: run"
  NOMAD_ACTION="run"
fi

if [ ${purge} ];
then
  FLAGS="${FLAGS} -purge"
fi

if [ -z $namespace ];
then
  FLAGS="${FLAGS} -namespace=${namespace}"
fi

if [ -z $region];
then
  FLAGS="${FLAGS} -region=${region}"
fi

if [ -z $token];
then
  FLAGS="${FLAGS} -token=${token}"
fi

if [ ${detach} ];
then
  FLAGS="${FLAGS} -detach"
fi

if ! command -v nomad &> /dev/null
then
  echo -e "Installing nomad..."
  curl -sS https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip && \
  unzip -qq nomad.zip && \
  mv nomad /usr/local/bin/ && \
  rm nomad.zip
  echo -e "Installed:" $(nomad version)
fi

echo -e "NOMAD_ADDR:" $NOMAD_ADDR "\nNOMAD_PORT:" $NOMAD_PORT "\nNOMAD_JOB:" $NOMAD_JOB"\nNOMAD_ACTION:" $NOMAD_ACTION
NOMAD_ADDR=${NOMAD_ADDR}:${NOMAD_PORT} nomad job ${NOMAD_ACTION} $FLAGS $GITHUB_WORKSPACE/$NOMAD_JOB
RESULT="$?"

# check if job was rolled back
if [ "$RESULT" == "0" ]; then
    NOMAD_ROLLBACK=$(echo "${NOMAD_RESULT}" | sed '/rolling back to job/h; ${p;x;/./Q3;Q0}')
    RESULT="$?"
fi

# check result of nomad job $NOMAD_ACTION
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
