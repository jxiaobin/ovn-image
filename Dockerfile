FROM ubuntu:latest
WORKDIR /opt
RUN set -e && \
    apt-get update -q -y --no-install-recommends && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -q -y --no-install-recommends \
        git \
        build-essential \
        ca-certificates \
        autoconf \
        automake \
        libtool \
        libssl-dev \
        graphviz \
        bzip2 \
        debhelper \
        dh-autoreconf \
        dh-python \
        openssl \
        procps \
        python3-all \
        python3-zope.interface \
        python3-sphinx \
        python3-twisted \
        libcap-ng-dev \
        libunbound-dev \
        libunwind-dev \
        fakeroot
RUN set -e && \
    mkdir packages && \
    git clone https://github.com/ovn-org/ovn && \
    cd ovn && \
    git submodule update --init && \
    cd ovs && \
    DEB_BUILD_OPTIONS='parallel=8 nocheck' fakeroot debian/rules binary && \
    cd .. && \
    mv *.deb /opt/packages && \
    dpkg -i /opt/packages/openvswitch-common*.deb /opt/packages/libopenvswitch*.deb  && \
    DEB_BUILD_OPTIONS='parallel=8 nocheck' fakeroot debian/rules binary && \
    cd .. && \
    mv *.deb /opt/packages

FROM ubuntu:latest
WORKDIR /opt
COPY --from=0 /opt/packages/ ./
COPY start.sh /usr/local/bin/start.sh
RUN set -e && \
    apt-get update -q -y --no-install-recommends && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -q -y --no-install-recommends \
        python3 \
        libssl-dev \
        openssl \
        libunwind8 \
        kmod \
        libkmod2 \
        netbase \
        uuid-runtime \
        libunbound-dev && \
    dpkg -i openvswitch-common*.deb libopenvswitch*.deb openvswitch-switch*.deb openvswitch-pki*.deb ovn-common*.deb ovn-central*.deb ovn-host*.deb && \
    rm -f * && \
    apt-get clean && rm -rf /var/lib/apt && rm -rf /var/cache/apt && \
    mkdir -p /var/run/ovn && \
    chmod +x /usr/local/bin/start.sh

VOLUME [ "/var/lib/openvswitch", "/etc/openvswitch", "/var/lib/ovn", "/etc/ovn" ]

# EXPOSE 6641
# EXPOSE 6642
# ENTRYPOINT ["/usr/local/bin/start.sh"]
