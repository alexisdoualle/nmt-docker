#!/bin.bash

onmt-main --model_type Transformer --config config.yml --auto_config --gpu_allow_growth train --with_eval >> preprocess_and_train.log --num_gpus 1
