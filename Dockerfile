FROM ubuntu:trusty
MAINTAINER Mike Ryan <falter@gmail.com>

ENV chopshop_brch=RELEASE_4.2
ENV crits_brch=master
ENV crits_services_brch=master

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    eatmydata apt-get install -y --fix-missing curl git \
      build-essential \
      curl \ 
      git \
      libevent-dev \
      libz-dev \
      libfuzzy-dev \
      libldap2-dev \
      libpcap-dev \
      libpcre3-dev \
      libsasl2-dev \
      libxml2-dev \
      libxslt1-dev \
      libyaml-dev \
      m2crypto \
      python-m2crypto \
      python-matplotlib \
      python-numpy \
      python-pycurl \
      python-pydot \
      python-pyparsing \
      python-setuptools \
      python-yaml \
      numactl \
      p7zip-full \
      python-dev \
      python-pip \
      ssdeep \
      unrar-free \
      upx \
      zip \
      swig \
      yara \
      tshark \
      tcpdump \
      libssl-dev \
      zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN eatmydata easy_install --script-dir=/usr/bin -U pip

RUN eatmydata /usr/bin/pip install \
      anyjson==0.3.3 \
      amqp \
      anyjson \
      billiard \
      biplist \
      bitstring==3.1.3 \
      cybox==2.1.0.5 \
      celery \
      python-dateutil==2.2 \
      defusedxml==0.4.1 \
      django==1.6.5 \
      django-celery \
      django-tastypie==0.11.0 \
      django-tastypie-mongoengine==0.4.5 \
      importlib==1.0.3 \
      kombu \
      lxml \
      libtaxii==1.1.102 \
      m2crypto \
      --allow-external mongoengine
      mongoengine==0.8.7 \
      olefile \
      pillow==2.4.0 \
      pydeep==0.2 \
      pymongo==2.7.2 \
      pyparsing \
      python-dateutil \
      python-ldap==2.4.15 \
      python-magic==0.4.6 \
      python-mimeparse \
      pytz \
      pyyaml \
      requests \
      setuptools \
      simplejson==3.5.2 \
      six \
      stix==1.1.1.0 \
      requests==1.1.0 \
      celery==3.0.12 \
      ushlex==0.99 \
      pymongo==2.7.2 \
      yara==1.7.7 \
      uwsgi==2.0.10 \
      dnslib==0.9.4 \
      wsgiref 

RUN eatmydata /usr/bin/pip install --allow-external pefile --allow-unverified pefile pefile
RUN eatmydata /usr/bin/pip install https://github.com/MITRECND/pynids/archive/0.6.2.zip
RUN eatmydata /usr/bin/pip install https://github.com/MITRECND/htpy/archive/RELEASE_0.21.zip

ENV HOME /root
RUN useradd -m crits

## Clone chopshop /data/chopshop

RUN \
    mkdir -p /data/chopshop && \
    git clone -b $chopshop_brch https://github.com/MITRECND/chopshop.git /data/chopshop && \
    chown -R crits:crits /data/chopshop

## Clone CRITs
RUN \
    mkdir -p /data/crits && \
    git clone -b $crits_brch https://github.com/crits/crits.git /data/crits && \
    chown -R crits:crits /data/crits

## Clone CRITs Services
RUN \
    mkdir -p /data/services-available && \
    git clone -b $crits_service_brch https://github.com/crits/crits_services.git /data/services-available && \
    chown -R crits:crits /data/services-available

ADD docker /docker

RUN mkdir /config
RUN cp /data/crits/crits/config/database_example.py /config
RUN cp /data/crits/crits/config/overrides_example.py /config
VOLUME [ "/config" ]
VOLUME [ "/data" ]

# HTTP socket
EXPOSE 8080
# uWSGI socket
EXPOSE 8001

WORKDIR /data/crits

CMD [ "start" ]

ENTRYPOINT [ "/bin/bash", "/docker/startup.sh" ]
