FROM tensorflow/tensorflow:1.13.1-gpu-py3
WORKDIR /usr/wezenmt
COPY ./requirements.txt .
RUN pip install -r requirements.txt
RUN apt install nano
RUN apt update
RUN apt install git -y
RUN git clone -b 'v0.1.85' --single-branch --depth 1 https://github.com/google/sentencepiece.git
RUN apt-get install cmake build-essential pkg-config libgoogle-perftools-dev -y
WORKDIR /usr/wezenmt/sentencepiece
RUN mkdir build
WORKDIR build
RUN cmake ..
RUN make -j $(nproc)
RUN make install
RUN ldconfig -v
run apt install screen
WORKDIR /usr/wezenmt
# ENTRYPOINT bash && /bin/bash './data/start.sh'
# CMD screen -dmS pre bash -c './data/start.sh; exec sh'
ENTRYPOINT screen -dmS pre bash -c './data/start.sh; exec sh' && bash