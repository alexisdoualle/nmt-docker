all: build run

build:
	@echo "\e[1m-------------------------------- Building wezenmt 🔧\e[0m"
	sudo docker build . -t wezenmt

run:
	@echo "\e[1m------------------------------- Launching wezenmt 🚀\e[0m"
	@sudo docker run --gpus all -p 6006:6006 -v `pwd`/data:/usr/wezenmt/data -v `pwd`/src:/usr/wezenmt/src -i -t wezenmt /bin/bash
