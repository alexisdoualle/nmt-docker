all: build run

build:
	@echo "\e[1m-------------------------------- Building wezenmt 🔧\e[0m"
	sudo docker build . -t wezenmt

kill:
	@sudo docker kill nmt
rm:
	@sudo docker rm nmt
run:
	@echo "\e[1m------------------------------- Launching wezenmt 🚀\e[0m"
	@sudo docker run -tid --name nmt -p 6006:6006 -v `pwd`/data:/usr/wezenmt/data -v `pwd`/src:/usr/wezenmt/src wezenmt /bin/bash
	@sudo docker exec -it nmt /bin/bash
