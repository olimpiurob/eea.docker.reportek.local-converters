#!/bin/bash

DEPATH="$1"
if [ -z "$DEPATH" ]; then
  DEPATH="/"
fi

DEPATHS=`find $DEPATH -name "*require*.yum"`
DEPENDENCIES=`for i in $DEPATHS; do cat $i; echo; done`

if [ ! -z "$DEPENDENCIES" ]; then
  echo "Running yum -y install $DEPENDENCIES"
  yum -y updateinfo
  yum -y install $DEPENDENCIES
  yum clean all
  rm -rf /var/tmp/*
fi
