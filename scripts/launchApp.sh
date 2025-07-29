#!/usr/bin/env bash

if [ "$2" == true ]; then
  uwsm app -- $TERMINAL -e $1  &> /home/tofix/test.test
else
  uwsm app -- $1 &> /home/tofix/test.test
fi

