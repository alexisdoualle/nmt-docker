#!/bin/bash

dir=$1
# Give some time for model initialization to happen
sleep 30
tensorboard --logdir=$dir --bind_all