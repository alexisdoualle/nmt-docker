#!/bin/bash

##################################################################################
# Preprocess Data for training a custom MT engine.
#
##################################################################################

# Files and directory
dir=$1
# set source and target languages
sl=$2
tl=$3

# for 4 GPUs: CUDA_VISIBLE_DEVICES=0,1,2,3
export CUDA_VISIBLE_DEVICES=0
export NVIDIA_VISIBLE_DEVICES=all
export NVIDIA_DRIVER_CAPABILITIES=compute,utility
export TF_FORCE_GPU_ALLOW_GROWTH=true

# filename same value as dir
fileName=$dir

# Extract data from TMX or text files
ls
cd src
npm install
node tmx-extract.js $sl $tl
node txt-extract.js $sl $tl
cd ..

# set vocabulary and validation size
vocab_size=16000
validationSize=2000

# create log output file
# touch data/preprocess_and_train.log

rm -rf data/$dir
rm -rf data/models
rm -rf data/models.zip

mkdir data/$dir

cd data/$dir
# Path where the source text files are located
txt=../extracted_data

files=$txt/*
nbFiles=${#files[@]}
echo ""
ls -l ../txt
echo "Number of files: $nbFiles"
if [ "$nbFiles" -eq "0" ]; then
  echo "No files found, exiting";
  exit;
fi
echo "Found following source files:"
for file in $files; do
  echo $file
done
echo ""

# set relevant paths
SP_PATH=/usr/local/bin
export PATH=$SP_PATH:$PATH

# Merge all files into training and validation files
for arg in $files; do
    ext=${arg: -3}
    # Only loop once for each s/t pair
    if [ $ext == .$tl ]; then
         continue
    fi
    temp=${arg%.*}
    file=${temp##*/} # Get basename without path
    echo "$file"":"

    # Check that files have the same number of lines
    slines=$(wc -l $txt/$file.$sl | cut -f1 -d' ')
    tlines=$(wc -l $txt/$file.$tl | cut -f1 -d' ')
    if [ $slines -eq $tlines ]; then
      echo "number of lines match: $slines"
    else
      echo "number of lines in source and target files don't match $slines / $tlines"
      exit
    fi

    half=$(($slines/2))
    
    if (($half < $validationSize)); then
      echo "number of lines smaller than validation size, using half of available data ($half lines)"
      head -n -$half $txt/$file.$sl >> $fileName-train.$sl
      head -n -$half $txt/$file.$tl >> $fileName-train.$tl
      tail -n -$half $txt/$file.$sl >> $fileName-valid.$sl
      tail -n -$half $txt/$file.$tl >> $fileName-valid.$tl
    else
      head -n -$validationSize $txt/$file.$sl >> $fileName-train.$sl
      head -n -$validationSize $txt/$file.$tl >> $fileName-train.$tl
      tail -n -$validationSize $txt/$file.$sl >> $fileName-valid.$sl
      tail -n -$validationSize $txt/$file.$tl >> $fileName-valid.$tl
    fi


done
  # decoding_subword_token: ▁

# Create config files:
rm -rf config.yml
touch config.yml
echo '
model_dir: '$fileName'_transformer_model

params:
  replace_unknown_target: true
  decoding_subword_token_is_spacer: true

data:
  train_features_file: '$fileName-'train.'$sl'.tok
  train_labels_file: '$fileName-'train.'$tl'.tok
  eval_features_file: '$fileName-'valid.'$sl'.tok
  eval_labels_file: '$fileName-'valid.'$tl'.tok
  source_vocabulary: '$fileName.vocab'
  target_vocabulary: '$fileName.vocab'

train:
  save_checkpoints_steps: 1000
  max_step: 70000
  early_stopping:
    metric: loss
    min_improvement: 0.01
    steps: 4

eval:
  steps: 500
  external_evaluators: BLEU
  export_on_best: bleu

infer:
  batch_size: 64

' >> config.yml

echo '
type: OpenNMTTokenizer
params:
  mode: none
  sp_model_path: '$fileName'.model

' >> token-config.yml

# set training, validation, and test corpuses
corpus[1]=$fileName-train
echo "$0: ${corpus[1]} lol"

if true; then
 echo "$0: Training sentencepiece model"
#  rm -f train.txt
 ls .
 for ((i=1; i<= ${#corpus[@]}; i++))
 do
  for f in ${corpus[$i]}.$sl ${corpus[$i]}.$tl
   do
    cat $f >> train.txt
   done
 done
fi

onmt-build-vocab --sentencepiece input_sentence_size=300000 shuffle_input_sentence=true --size 20000 --save_vocab $fileName train.txt
cat $fileName-train.$sl | onmt-tokenize-text --tokenizer_config token-config.yml >> $fileName-train.$sl.tok
cat $fileName-valid.$sl | onmt-tokenize-text --tokenizer_config token-config.yml >> $fileName-valid.$sl.tok
cat $fileName-train.$tl | onmt-tokenize-text --tokenizer_config token-config.yml >> $fileName-train.$tl.tok
cat $fileName-valid.$tl | onmt-tokenize-text --tokenizer_config token-config.yml >> $fileName-valid.$tl.tok

rm train.txt
rm $fileName-train.$sl
rm $fileName-valid.$sl
rm $fileName-train.$tl
rm $fileName-valid.$tl

echo "End of sentencepiece training"
echo "***"
echo ""


# Spec file
rm -rf training-specs.txt
touch training-specs.txt
echo "Model name: "$fileName"_transformer_model" >> training-specs.txt
echo "Size of training corpus: "$(($slines - $validationSize))" lines" >> training-specs.txt
echo "Size of validation corpus: "$validationSize" lines" >> training-specs.txt
echo "Tokenizer: Sentencepiece " >> training-specs.txt
echo "Vocab size: "$vocab_size >> training-specs.txt

# Run Tensorboard in new process (--bind_all needed to be accessible outside of container)
pkill tensorboard
#tensorboard --logdir ${fileName}_transformer_model --bind_all &
./../../src/tensorboard.sh $fileName/${fileName}_transformer_model &

onmt-main --model_type Transformer --config config.yml --auto_config --gpu_allow_growth train --with_eval >> preprocess_and_train.log --num_gpus 1

# After training is completed
cd ../..
# chmod -R 777 ./
./src/export_model.sh $1 $2 $3

# zip -R $fileName_transformer_model/export/

exit
# Use python3 virtualenv with tensorflow installed (and cuda etc.) and OpenNMT-tf to launch training

# TRAINING (cd $dir) OLD (1.x)
# onmt-main train_and_eval --model_type Transformer --config config.yml --auto_config

# Generate serving config file
# ./prepareServing.sh

# SERVING
# From OpenNMT-tf/scripts/mf: servers
# sudo docker run -td --name <name> -p 5000:5000 -v $PWD:/root/models nmtwizard/opennmt-tf --model <model-name> --model_storage /root/models serve --host 0.0.0.0 --port 5000

sudo docker run -td --name mda -p 5000:5000 -v $PWD:/root/models nmtwizard/opennmt-tf --model test_transformer_model --model_storage /root/models serve --host 0.0.0.0 --port 5000

#./preprocess_sp.sh ENSV_Para_bikes en sv ENSV_Para_bikes/Bike_descriptions ENSV_Para_bikes/Product_descriptions_bikes ENSV_Para_bikes/Keywords ENSV_Para_bikes/en-sv.bicleaner07
