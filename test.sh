#!/bin/bash

cd `dirname $0`
exitcode=0

if [[ ! -d ./tests/testbox ]] ; then
	box install
fi

box stop name="stickertests"
box start directory="./tests/" serverConfigFile="./tests/server-sticker-tests.json"
box testbox run verbose=false || exitcode=1
box stop name="stickertests"

exit $exitcode
