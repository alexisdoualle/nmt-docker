#!/bin/bash

echo "*********************************"
echo "** Preparing model for serving **"
echo "*********************************"
echo ""

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

cd data/$dir/$fileName\_transformer_model

# Generate serving config file
models=$(ls -vr ./export)
latestModel=$(echo $models | awk '{print $1;}')

echo "**** Latest model: $latestModel (steps)"

# Copy files in '1'
rm -rf saved_model
mkdir saved_model
cd saved_model
mkdir assets/
mkdir variables
cp ../../$fileName-$sl$tl.model assets/
cp ../export/$latestModel/assets/*.vocab assets/
cp ../export/$latestModel/variables/* variables/
cp ../export/$latestModel/saved_model.pb .

cd ..
rm -rf config.json
touch config.json
# echo '
# {
#     "source": "'$sl'",
#     "target": "'$tl'",
#     "model": "'$fileName'_transformer_model",
#     "modelType": "release",
#     "tokenization": {
#         "source": {
#             "mode": "none",
#             "sp_model_path": "${MODEL_DIR}/saved_model/assets/'$fileName-$sl$tl'.model",
#             "vocabulary": "${MODEL_DIR}/saved_model/assets/'$fileName-$sl$tl'.vocab"
#         },
#         "target": {
#             "mode": "none",
#             "sp_model_path": "${MODEL_DIR}/saved_model/assets/'$fileName-$sl$tl'.model",
#             "vocabulary": "${MODEL_DIR}/saved_model/assets/'$fileName-$sl$tl'.vocab"
#         }
#     }
# }
# ' >> config.json

echo '
{
    "source": "'$sl'",
    "target": "'$tl'",
    "model": "'$fileName'_transformer_model",
    "modelType": "release",
    "vocabulary": {
        "source": {
            "vocabulary": "${MODEL_DIR}/saved_model/assets/'$fileName-$sl'.vocab"
        },
        "target": {
            "vocabulary": "${MODEL_DIR}/saved_model/assets/'$fileName-$tl'.vocab"
        }
    },
    "options": {
        "model_type": "Transformer",
        "auto_config": true
    }
}
' >> config.json

rm -rf ../../models

mkdir ../../models
mkdir ../../models/${fileName}_transformer_model
mv saved_model ../../models/${fileName}_transformer_model
mv config.json ../../models/${fileName}_transformer_model
cd ../..
zip -r models.zip models
chmod -R 777 models.zip

echo "Done!"

# echo '***removing previous container: ***'
# sudo docker kill mda
# sudo docker container rm mda

# cd ..
# # Run from "$dir" folder
# # echo 'sudo docker run -td --name mda -p 5000:5000 -v $PWD:/root/models nmtwizard/opennmt-tf --model '$fileName'_transformer_model --model_storage /root/models serve --host 0.0.0.0 --port 5000'
# sudo docker run -td --name mda -p 5000:5000 -v $PWD:/root/models nmtwizard/opennmt-tf --model $fileName\_transformer_model --model_storage /root/models serve --host 0.0.0.0 --port 5000
# echo ''

# echo 'Wait a few seconds and check container status (should be "UP")'
# sleep 3
# sudo docker container list -all
# echo ''
# echo 'If image is running, POST on http://localhost:5000/translate with body: {"src": [{"text": "Hello"}]}'

