# bitcoinsv-testnet-box docker image

# Ubuntu 14.04 LTS (Trusty Tahr)
FROM ubuntu:18.04
LABEL maintainer="Edward Boggis-Rolfe<edward@boggis-rolfe.com>"

ENV BSV_VERSION=0.1.1

# add bitcoind from the official PPA
# install bitcoind (from PPA) and make
RUN apt-get update && \
	apt-get install --yes vim software-properties-common curl make git build-essential libzmq3-dev libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils libboost-all-dev libdb-dev libdb++-dev

RUN git clone https://github.com/bitcoin-sv/bitcoin-sv.git --branch v0.1.1 /root/bitcoin-sv
WORKDIR /root/bitcoin-sv
RUN ./autogen.sh
RUN ./configure --disable-tests
RUN make -j8
RUN make install
	
# create a non-root user
RUN adduser --disabled-login --gecos "" tester

# run following commands from user's home directory
WORKDIR /home/tester

# copy the testnet-box files into the image
ADD . /home/tester/bitcoinsv-testnet-box

# make tester user own the bitcoinsv-testnet-box
RUN chown -R tester:tester /home/tester/bitcoinsv-testnet-box

# color PS1
RUN mv /home/tester/bitcoinsv-testnet-box/.bashrc /home/tester/ && \
	cat /home/tester/.bashrc >> /etc/bash.bashrc

# use the tester user when running the image
USER tester

# run commands from inside the testnet-box directory
WORKDIR /home/tester/bitcoinsv-testnet-box

# expose two rpc ports for the nodes to allow outside container access
EXPOSE 19001 19011
CMD ["/bin/bash"]
