#!/bin.bash
ls -l
echo "starting"
for i in 5 4 3 2 1;
    do echo $i;
    sleep 10;
done
source "./data/preprocess.sh"