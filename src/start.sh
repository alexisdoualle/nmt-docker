#!/bin.bash

echo "starting.."
echo "Project name: $1"
echo "source language: $2"
echo "target language: $3"
echo "********"
ls -l .
ls -l /root/
/bin/bash /root/src/preprocess.sh $1 $2 $3