#!/usr/bin/env bash

repo=`pwd | rev | cut -d '/' -f 1 |rev`

echo "================================================================================================"
echo "         					BUILD_AND_DEPLOY ($repo) "
echo "================================================================================================"

docker build -t coap-server . 

docker run --network host -p 5683:5683 coap-server 
