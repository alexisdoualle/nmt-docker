run:
	make -k r
	
r: 
	make kill rm rn log

build:
	@echo "\e[1m-------------------------------- Building wezenmt 🔧\e[0m"
	sudo docker build . -t wezenmt

kill:
	@sudo docker kill nmt
rm:
	@sudo docker rm nmt
rn:
	@echo "\e[1m------------------------------- Launching wezenmt 🚀\e[0m"
	@sudo docker run -d --name nmt -p 6006:6006 -v `pwd`/data:/home/wezenmt/data -v `pwd`/src:/home/wezenmt/src --gpus=all wezenmt istores en nb
	# @sudo docker exec -it nmt /bin/bash
log:
	@sudo docker logs nmt --follow
