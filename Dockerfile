FROM ubuntu:focal

RUN \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install \
		--no-install-recommends -y \
		build-essential meson ninja-build python3-pyelftools \
		libnuma-dev git libpcap-dev libjansson-dev libssl-dev \
		zlib1g-dev libatomic1 \
		libnl-route-3-dev chrpath dpatch autotools-dev \
		debhelper libnl-3-dev pciutils ethtool python3-distutils \
		libnl-3-200 dkms libltdl-dev quilt m4 lsof autoconf swig \
		automake linux-headers-5.4.0-81-generic libnl-route-3-200 \
		udev libpython3.8 pkg-config \
		traceroute tcptraceroute net-tools \
		inetutils-ping tcpdump ltrace strace iproute2 less \
		bind9-host bind9-dnsutils

COPY MLNX_OFED_LINUX-5.4-1.0.3.0-ubuntu20.04-x86_64.tgz /tmp

RUN \
	cd /tmp && \
	tar zxf MLNX_OFED_LINUX-5.4-1.0.3.0-ubuntu20.04-x86_64.tgz && \
	rm MLNX_OFED_LINUX-5.4-1.0.3.0-ubuntu20.04-x86_64.tgz && \
	cd MLNX_OFED_LINUX-5.4-1.0.3.0-ubuntu20.04-x86_64 && \
	echo y | ./mlnxofedinstall \
		--all --without-fw-update \
	&& \
	cd .. && \
	rm -rf MLNX_OFED_LINUX-5.4-1.0.3.0-ubuntu20.04-x86_64

RUN \
	apt-get install -y curl && \
	cd /tmp && \
	curl -o dpdk-20.11.2.tar.xz https://fast.dpdk.org/rel/dpdk-20.11.2.tar.xz && \
	tar Jxf dpdk-20.11.2.tar.xz && \
	cd dpdk-stable-20.11.2 && \
	meson -Dexamples=all build && \
	ninja -C build && \
	ninja -C build install && \
	ldconfig && \
	cd .. && \
	rm -rf dpdk-stable-20.11.2

RUN \
	cd /usr/local && \
	git clone http://dpdk.org/git/apps/pktgen-dpdk && \
	cd pktgen-dpdk && \
	make && \
	make install && \
	ln -s \
		/usr/local/pktgen-dpdk/usr/local/bin/pktgen \
		/usr/local/bin/pktgen && \
	apt-get --purge -y remove gcc g++ binutils build-essential autoconf \
		automake autotools-dev meson ninja-build git swig m4 dkms && \
	apt-get --purge -y autoremove && \
	apt-get clean
