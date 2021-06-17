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
	@sudo docker run -d --name nmt -p 6006:6006 -v `pwd`/data:/root/data -v `pwd`/src:/root/src --gpus all wezenmt fashion en fr

shell:
	@sudo docker run --entrypoint bash -it --name nmt -p 6006:6006 -v `pwd`/data:/root/data -v `pwd`/src:/root/src --gpus all wezenmt

attach_shell:
	@sudo docker exec -it nmt bash

log:
	@sudo docker logs nmt --follow
