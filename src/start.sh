#!/bin.bash

echo "starting.."
echo "Project name: $1"
echo "source language: $2"
echo "target language: $3"
ls -l /home/wezenmt/src/
/bin/bash /home/wezenmt/src/preprocess.sh $1 $2 $3