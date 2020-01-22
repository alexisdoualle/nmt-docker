#!/bin/bash

##################################################################################
# Preprocess Data for training a custom MT engine.
#
# Developped from https://github.com/OpenNMT/OpenNMT-tf/blob/master/scripts/mf/prepare_data.sh
#
# Expects two files (<fileName>), plain text, source and target (file extensions), with parallel lines
##################################################################################

# Files and directory
# dir=Motoblouz
# fileName=Motoblouz_BLOG_FR-ES
dir=$1
# set source and target languages
sl=$2
tl=$3

# vocab_size=$4
# validationSize=$5

# filename same value as dir
# fileName=${1##*/}
fileName=$dir

#files=("${@:6}")

# set vocabulary and validation size
vocab_size=16000
validationSize=1000

mkdir data/$dir

cd data/$dir

# Path where the source text files are located
txt=../txt

files=$txt/*
echo ""
echo "Found following source files:"
for file in $files; do
  echo $file
done
echo ""
# mkdir -p raw_data
# cd raw_data

# set relevant paths
SP_PATH=/usr/local/bin
export PATH=$SP_PATH:$PATH

# DATA_PATH=raw_data
# TEST_PATH=raw_data/test

# Separate part of the training corpus for training, validation (and maybe test) files
rm $fileName-train.$sl
rm $fileName-train.$tl
rm $fileName-valid.$sl
rm $fileName-valid.$tl

touch $fileName-train.$sl
touch $fileName-train.$tl
touch $fileName-valid.$sl
touch $fileName-valid.$tl
# touch $fileName-test.$sl
# touch $fileName-test.$tl

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
    echo "number of lines smaller than validation size, using half of available data ($half lines)"
    
    if (($slines/2 < $validationSize)); then
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

# Create config files:
rm -rf config.yml
touch config.yml
echo '
model_dir: '$fileName'_transformer_model

data:
  train_features_file: data/'$fileName-'train.'$sl'
  train_labels_file: data/'$fileName-'train.'$tl'
  eval_features_file: data/'$fileName-'valid.'$sl'
  eval_labels_file: data/'$fileName-'valid.'$tl'
  source_vocabulary: data/'$fileName-$sl$tl.vocab'
  target_vocabulary: data/'$fileName-$sl$tl.vocab'

train:
  save_checkpoints_steps: 1000
  train_steps: 80000
  max_step: 80000

eval:
  steps: 60000
  external_evaluators: BLEU
  export_on_best: bleu
  early_stopping:
    min_improvement: 0.01
    steps: 5
infer:
  batch_size: 64

' >> config.yml

# for arg in "${files[@]}"; do
#    echo "$arg"
#    corpus[1]=$arg-train
# done

# for ((i=1; i<= ${#files[@]}; i++))

# set training, validation, and test corpuses
corpus[1]=$fileName-train
# corpus[2]=training-parallel-commoncrawl
# etc...

# Data preparation using SentencePiece
# First we concat all the datasets to train the SP model
if true; then
 mkdir -p data
 echo "$0: Training sentencepiece model"
 rm -f data/train.txt
 ls .
 for ((i=1; i<= ${#corpus[@]}; i++))
 do
  for f in ${corpus[$i]}.$sl ${corpus[$i]}.$tl
   do
    cat $f >> data/train.txt
   done
 done
#  python -c "import sentencepiece as spm; spm.SentencePieceTrainer.Train('--input=data/train.txt --model_prefix=$fileName-$sl$tl --vocab_size=$vocab_size --character_coverage=1 --input_sentence_size=1000000 --shuffle_input_sentence=true');"
 spm_train --input=data/train.txt --model_prefix=$fileName-$sl$tl \
           --vocab_size=300 --character_coverage=1 --hard_vocab_limit=false --input_sentence_size=1000000 --shuffle_input_sentence=true
 rm data/train.txt
fi

# Second we use the trained model to tokenize all the files
if true; then
 echo "$0: Tokenizing with sentencepiece model"
 rm -f data/train.txt
 for ((i=1; i<= ${#corpus[@]}; i++))
 do
  for f in ${corpus[$i]}.$sl ${corpus[$i]}.$tl
   do
    file=$(basename $f)
    spm_encode --model=$fileName-$sl$tl.model < $f > data/$file.sp
   done
 done
fi

# We concat the training sets into two (src/tgt) tokenized files
if true; then
 cat data/*.$sl.sp > data/$fileName-train.$sl
 cat data/*.$tl.sp > data/$fileName-train.$tl
fi

#  We use the same tokenization method for a valid set (and test set)
echo "creating validation files"
if true; then
    spm_encode --model=$fileName-$sl$tl.model < $fileName-valid.$sl > data/$fileName-valid.$sl
    spm_encode --model=$fileName-$sl$tl.model < $fileName-valid.$tl > data/$fileName-valid.$tl
    # spm_encode --model=$fileName-$sl$tl.model < test.$sl-$tl.$sl > data/test.$sl
    # spm_encode --model=$fileName-$sl$tl.model < test.$sl-$tl.$tl > data/test.$tl
fi
# Let's finish and clean up
mv $fileName-$sl$tl.model data/$fileName-$sl$tl.model

# We keep the first field of the vocab file generated by SentencePiece and remove the first line <unk>
cut -f 1 $fileName-$sl$tl.vocab | tail -n +2 > data/$fileName-$sl$tl.vocab.tmp

# we add the <blank> word in first position, needed for OpenNMT-TF
sed -i '1i<blank>' data/$fileName-$sl$tl.vocab.tmp

# Last tweak we replace the empty line supposed to be the "tab" character (removed by the cut above)
perl -pe '$/=""; s/\n\n/\n\t\n/;' data/$fileName-$sl$tl.vocab.tmp > data/$fileName-$sl$tl.vocab
rm data/$fileName-$sl$tl.vocab.tmp

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
tensorboard --logdir ${fileName}_transformer_model --bind_all &

onmt-main --model_type Transformer --config config.yml --auto_config train --with_eval

exit
# Use python3 virtualenv with tensorflow installed (and cuda etc.) and OpenNMT-tf to launch training

# TRAINING (cd $dir) OLD (1.x)
# onmt-main train_and_eval --model_type Transformer --config config.yml --auto_config

# Generate serving config file
# ./prepareServing.sh

# SERVING
# From OpenNMT-tf/scripts/mf: servers
# sudo docker run -td --name <name> -p 5000:5000 -v $PWD:/root/models nmtwizard/opennmt-tf --model <model-name> --model_storage /root/models serve --host 0.0.0.0 --port 5000

sudo docker run -td --name mda -p 5000:5000 -v $PWD:/root/models nmtwizard/opennmt-tf --model MF20190726enGBfrFR_transformer_model --model_storage /root/models serve --host 0.0.0.0 --port 5000

#./preprocess_sp.sh ENSV_Para_bikes en sv ENSV_Para_bikes/Bike_descriptions ENSV_Para_bikes/Product_descriptions_bikes ENSV_Para_bikes/Keywords ENSV_Para_bikes/en-sv.bicleaner07
