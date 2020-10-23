FROM tensorflow/tensorflow:latest-gpu-py3
WORKDIR /home/wezenmt
COPY ./requirements.txt .
RUN pip install -r requirements.txt
RUN apt update
RUN apt install nvidia-modprobe
RUN apt install nano
RUN apt install git -y
RUN git clone https://github.com/google/sentencepiece.git
RUN apt-get install cmake build-essential pkg-config libgoogle-perftools-dev -y
WORKDIR /home/wezenmt/sentencepiece
RUN mkdir build
WORKDIR build
RUN cmake ..
RUN make -j $(nproc)
RUN make install
RUN ldconfig -v
RUN apt-get install curl -y
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash
RUN apt-get install --yes nodejs
RUN node -v
RUN npm -v
RUN apt-get install zip
WORKDIR /home/wezenmt
COPY ./src/start.sh /
RUN chmod +x /start.sh
ENTRYPOINT ["sh", "/start.sh"]
# CMD ["test", "en", "sv"] 
