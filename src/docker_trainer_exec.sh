#!/bin/sh -e
S3_BUCKET=$1
S3_FOLDER=$2
SRC_LANG=$3
TRG_LANG=$4
START_TIME=$5

# 00_declare_nvidia_gpus
export CUDA_VISIBLE_DEVICES=0,1,2,3
export NVIDIA_VISIBLE_DEVICES=all
export NVIDIA_DRIVER_CAPABILITIES=compute,unity

calc(){ awk "BEGIN { print "$*" }"; }

# 00.1_special_slack_notification
send_slack_alert() {

    VM_HOUR_PRICE=12.24 # static var

    # 0_get_the_time_in_milliseconds_when_Docker_finished_it_job
    END_DATE=$(($(date +%s%N)/1000000))

    # 1_get_the_mt_training_total_durationin_minutes
    TIME=$((((${END_DATE}-${START_TIME})/1000)/60))

    # 2_compute_the_cost_for_this_training
    COST=$(calc ${VM_HOUR_PRICE}/$(calc 60/${TIME}))

    CHANNEL="wzn-aws-mt-system"
    USERNAME="AWS Bot"
    MSG="<!channel> MT Training for "${S3_FOLDER}" with languages ["${SRC_LANG}"-"${TRG_LANG}"] has finished. *Total Time: "${TIME}" minute(s)* / Estimated Cost: *\$"${COST}"* / VM Cost (per hour): \$"${VM_HOUR_PRICE}

    PAYLOAD="payload={\"channel\": \"${CHANNEL}\", \"username\": \"${USERNAME}\", \"text\": \"${MSG}\"}"

    HOOK=https://hooks.slack.com/services/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

    curl -X POST --data-urlencode "${PAYLOAD}" "${HOOK}"
}

# 01_current_date_for_log_files
DATE=$(date --iso-8601=minutes)

# 02_clean_old_docker
docker stop nmt || true && docker rm nmt || true

# 03_clean_workspace
mkdir -p /root/nmt-docker && rm -rf /root/nmt-docker/*

# 04_load_docker_requirements
aws s3 sync s3://${S3_BUCKET}/builds/docker-dependencies/ /root/nmt-docker/

# 05_set_sh_executables_for_root
chmod -R u+x /root/nmt-docker/src/*.sh

# 06.1_unzip_tmx_and_properties
unzip /root/corpus/tmx.zip

# 06.2_drag_tmx_corpus_files_to_docker_workspace
mkdir -p /root/nmt-docker/data/tmx/ && mv /root/tmx/*.tmx /root/nmt-docker/data/tmx/

# 06.3_drag_txt_corpus_files_to_docker_workspace
mkdir -p /root/nmt-docker/data/txt/
mv /tmx/*.${SRC_LANG} /root/nmt-docker/data/txt/
mv /tmx/*.${TRG_LANG} /root/nmt-docker/data/txt/

# 06.3_get_properties
# PROPERTIES="/root/corpus/model.properties"
# if [ -f "$PROPERTIES" ]
# then
#   echo "Reading $PROPERTIES..."
#   while IFS='=' read -r key value
#   do
#     key=$(echo $key | tr '.' '_')
#     eval ${key}=\${value}
#   done < "$PROPERTIES"
# else
#   echo "Error: file not found"
# fi

# echo "source language: $source_language"
# echo "target language: $target_language"

echo "*********************************"
echo "**** Building Docker image... ***"
echo "*********************************"
echo ""

# 07_launch_docker_and_MT_training
cd /root/nmt-docker
docker build . -t wezenmt
nvidia-docker run -d --name nmt -p 6006:6006 -v `pwd`/data:/home/wezenmt/data -v `pwd`/src:/home/wezenmt/src wezenmt model ${SRC_LANG} ${TRG_LANG}
docker wait nmt

# 08_upload_trained_model_on_S3
aws s3 cp /root/nmt-docker/data/models.zip s3://${S3_BUCKET}/${S3_FOLDER}/${SRC_LANG}-${TRG_LANG}/models/models.zip

send_slack_alert

sleep 5m

# 09_shutdown_the_expensive_server
shutdown -h now