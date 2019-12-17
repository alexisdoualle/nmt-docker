#!/bin/bash

dir=$1
# set source and target languages
sl=$2
tl=$3
fileName=${1##*/}
echo $fileName
#dir=ENSV_Para_bikes
#fileName=ENSV_Para_bikes
#sl=en
#tl=sv

cd $dir/$fileName\_transformer_model

# Generate serving config file
models=$(ls -r export/latest)
latestModel=$(echo $models | awk '{print $1;}')

# Copy files in '1'
rm -rf 1
mkdir 1
cd 1
mkdir assets
mkdir variables
cp ../../data/$fileName-$sl$tl.model assets/
cp ../export/latest/$latestModel/assets/$fileName-$sl$tl.vocab assets/
cp ../export/latest/$latestModel/variables/variables.data-00000-of-00001 variables/
cp ../export/latest/$latestModel/variables/variables.index variables/
cp ../export/latest/$latestModel/saved_model.pb .

cd ..
rm -rf config.json
touch config.json
echo '
{
    "source": "'$sl'",
    "target": "'$tl'",
    "model": "'$fileName'_transformer_model",
    "modelType": "release",
    "tokenization": {
        "source": {
            "mode": "none",
            "sp_model_path": "${MODEL_DIR}/1/assets/'$fileName-$sl$tl'.model",
            "vocabulary": "${MODEL_DIR}/1/assets/'$fileName-$sl$tl'.vocab"
        },
        "target": {
            "mode": "none",
            "sp_model_path": "${MODEL_DIR}/1/assets/'$fileName-$sl$tl'.model",
            "vocabulary": "${MODEL_DIR}/1/assets/'$fileName-$sl$tl'.vocab"
        }
    }
}
' >> config.json

echo '***removing previous container: ***'
sudo docker kill mda
sudo docker container rm mda

cd ..
# Run from "$dir" folder
# echo 'sudo docker run -td --name mda -p 5000:5000 -v $PWD:/root/models nmtwizard/opennmt-tf --model '$fileName'_transformer_model --model_storage /root/models serve --host 0.0.0.0 --port 5000'
sudo docker run -td --name mda -p 5000:5000 -v $PWD:/root/models nmtwizard/opennmt-tf --model $fileName\_transformer_model --model_storage /root/models serve --host 0.0.0.0 --port 5000
echo ''

echo 'Wait a few seconds and check container status (should be "UP")'
sleep 3
sudo docker container list -all
echo ''
echo 'If image is running, POST on http://localhost:5000/translate with body: {"src": [{"text": "Hello"}]}'

