#!/bin/bash

dir=$1
# Give some time for model initialization to happen
echo "**** Starting tensorboard in 60s ****"
sleep 60
echo "*********************************"
echo "**** Tensorboard starting... ****"
echo "*********************************"
tensorboard --logdir=/root/data/$dir --bind_all