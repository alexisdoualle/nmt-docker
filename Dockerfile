
FROM nvidia/cuda:10.1-cudnn7-runtime-ubuntu18.04

WORKDIR /root

ENV NODE_VERSION=10.24.1
ENV PYTHONDONTWRITEBYTECODE=1
ENV LANG=C.UTF-8

# RUN apt-get update && \
#     apt-get install wget curl ca-certificates rsync -y
# RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
# ENV NVM_DIR=/root/.nvm
# RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
# RUN . "$NVM_DIR/nvm.sh" &&  nvm use v${NODE_VERSION}
# RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
# RUN cp /root/.nvm/versions/node/v${NODE_VERSION}/bin/node /usr/bin/
# RUN cp /root/.nvm/versions/node/v${NODE_VERSION}/bin/npm /usr/bin/
# RUN /root/.nvm/versions/node/v${NODE_VERSION}/bin/npm install  leasot@latest -g

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nodejs \
        npm \
        libnvinfer6=6.0.1-1+cuda10.1 \
        libnvinfer-plugin6=6.0.1-1+cuda10.1 \
        python3-distutils \
        wget \
        && \
    wget -nv https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py && \
    rm get-pip.py && \
    apt-get autoremove -y wget && \
    rm -rf /var/lib/apt/lists/*

ADD base_requirements.txt /root
ADD requirements.txt /root
RUN python3 -m pip --no-cache-dir install -r /root/base_requirements.txt -r /root/requirements.txt

RUN apt-get update && \
    apt-get install -y zip

COPY ./src/start.sh /    
RUN chmod +x /start.sh

ENTRYPOINT ["sh", "/start.sh"]

# FROM nvidia/cuda:10.1-cudnn7-runtime-ubuntu18.04
# WORKDIR /home/wezenmt
# COPY ./requirements.txt .
# RUN apt update && apt install python3-pip -yRien
# RUN pip3 install --upgrade pip
# RUN pip3 install -r requirements.txt
# RUN apt update
# # RUN apt install nvidia-modprobe
# RUN apt install nano
# RUN apt install git -y
# # RUN git clone https://github.com/google/sentencepiece.git
# # RUN apt-get install cmake build-essential pkg-config libgoogle-perftools-dev -y
# # WORKDIR /home/wezenmt/sentencepiece
# # RUN mkdir build
# # WORKDIR build
# # RUN cmake ..
# # RUN make -j $(nproc)
# # RUN make install
# # RUN ldconfig -v
# RUN apt-get install curl -y
# RUN curl -sL https://deb.nodesource.com/setup_10.x | bash
# RUN apt-get install --yes nodejs
# RUN node -v
# RUN npm -v
# RUN apt-get install zip -y
# WORKDIR /home/wezenmt
# COPY ./src/start.sh /
# RUN chmod +x /start.sh
# ENTRYPOINT ["sh", "/start.sh"]
# # CMD ["test", "en", "sv"] 
