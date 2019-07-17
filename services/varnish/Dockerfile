FROM ubuntu:bionic

USER root

ENV DEBIAN_FRONTEND=noninteractive

RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90tugboat && \
    echo 'DPkg::Options "--force-confnew";' >> /etc/apt/apt.conf.d/90tugboat && \
    (grep Linux\ 7 /etc/issue && echo "deb http://http.debian.net/debian wheezy-backports main" > /etc/apt/sources.list.d/wheezy-backports.list || /bin/true) && \
    (apt-get update || /bin/true) && \
    \
    apt-get install apt-transport-https && \
    apt-get update && \
    \
    mkdir -p /usr/share/man/man1 && \
    mkdir -p /etc/service && \
    mkdir -p /usr/share/tugboat && \
    \
    apt-get install -y \
        git locales sudo openssh-client ca-certificates tar gzip build-essential \
        net-tools netcat-openbsd unzip zip bzip2 gnupg curl wget vim runit \
        rsync apt-transport-https && \
    (grep Linux\ 7 /etc/issue && apt-get -t wheezy-backports install -y git || /bin/true) && \
    \
    echo "[user]" > ~/.gitconfig && \
    echo "    email = root@tugboat.qa" >> ~/.gitconfig && \
    echo "    name = Tugboat" >> ~/.gitconfig && \
    \
    ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    \
    localedef -i en_US -c -f UTF-8 en_US.UTF-8 && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    touch /usr/share/locale/locale.alias && \
    locale-gen

# Configure locale
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

COPY share/README.txt /usr/share/tugboat/
COPY share/Makefile /usr/share/tugboat/

RUN curl -L https://packagecloud.io/varnishcache/varnish60lts/gpgkey | sudo apt-key add - && \
    echo 'deb https://packagecloud.io/varnishcache/varnish60lts/ubuntu/ bionic main' >> /etc/apt/sources.list.d/varnishcache_varnish60lts.list && \
    echo 'deb-src https://packagecloud.io/varnishcache/varnish60lts/ubuntu/ bionic main' >> /etc/apt/sources.list.d/varnishcache_varnish60lts.list && \
    apt-get update && \
    apt-get install varnish

# This is the common entrypoint script used by official images.
COPY files/usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Check the Varnish administration interface
HEALTHCHECK CMD /bin/nc -z 127.0.0.1 6082

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /etc/service/varnish
COPY run /etc/service/varnish/run

CMD ["/usr/bin/runsvdir", "-P", "/etc/service"]
