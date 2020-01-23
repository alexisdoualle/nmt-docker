all: build kill rm run
r: kill rm run

build:
	@echo "\e[1m-------------------------------- Building wezenmt 🔧\e[0m"
	sudo docker build . -t wezenmt

kill:
	@sudo docker kill nmt
rm:
	@sudo docker rm nmt
run:
	@echo "\e[1m------------------------------- Launching wezenmt 🚀\e[0m"
	@sudo docker run -d --name nmt -p 6006:6006 -v `pwd`/data:/home/wezenmt/data -v `pwd`/src:/home/wezenmt/src wezenmt
	# @sudo docker exec -it nmt /bin/bash
log:
	@sudo docker logs nmt --follow