FROM ubuntu:16.04

ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN apt-get update
RUN apt-get install -y gcc
RUN apt-get install -y g++
RUN apt-get install -y make
RUN apt-get install -y wget && rm -rf /var/lib/apt/lists/*

RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh 
RUN conda --version

# Configure Services and Port
COPY start.sh /start.sh
CMD ["./start.sh"]

COPY BN2Distribute.tar.gz /opt
COPY xerces-c-src_2_8_0.tar.gz /opt

ENV XERCESCROOT=/opt/xerces-c-src_2_8_0

WORKDIR /opt
RUN tar -xvf BN2Distribute.tar.gz
RUN tar -xvf xerces-c-src_2_8_0.tar.gz
WORKDIR xerces-c-src_2_8_0/src/xercesc
RUN ./runConfigure -plinux -cgcc -xg++ -minmem -nsocket -tnative -rpthread -b64
RUN make

WORKDIR /opt/BN2Distribute/BN
RUN make -f Makefile testBN
RUN ln -s /opt/xerces-c-src_2_8_0/lib/libxerces-c.so.28 /usr/lib/libxerces-c.so.28
ENV testBN=/opt/BN2Distribute/BN/testBN

EXPOSE 80 443
