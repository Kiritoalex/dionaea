# dionaea dockerfile by MO 
#
# VERSION 0.4
FROM ubuntu:14.04.1
MAINTAINER Drops

# Ui install
RUN apt-get update
RUN apt-get install -y python-pip python-dev git wget unzip
RUN apt-get upgrade
RUN pip install Django pygeoip django-pagination django-tables2 django-compressor django-htmlmin django-filter

# django-tables2-simplefilter
RUN wget https://github.com/benjiec/django-tables2-simplefilter/archive/master.zip -O django-tables2-simplefilter.zip
RUN git clone git://git.bro-ids.org/pysubnettree.git
RUN unzip django-tables2-simplefilter.zip
WORKDIR django-tables2-simplefilter-master
RUN ls -l 
RUN python setup.py install
WORKDIR /pysubnettree
RUN python setup.py install
WORKDIR /

# nodejs
RUN wget http://nodejs.org/dist/v0.10.33/node-v0.10.33.tar.gz
RUN tar xzvf node-v0.10.33.tar.gz
WORKDIR node-v0.10.33
RUN /node-v0.10.33/configure
RUN make
RUN make install
WORKDIR /
RUN npm install -g less
RUN apt-get install -y python-netaddr

# RF
RUN wget https://github.com/RootingPuntoEs/DionaeaFR/archive/master.zip -O DionaeaFR.zip
RUN unzip DionaeaFR.zip

# GeoIP
RUN wget -P DionaeaFR-master/DionaeaFR/static http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
RUN wget -P DionaeaFR-master/DionaeaFR/static http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
RUN gunzip DionaeaFR-master/DionaeaFR/static/GeoLiteCity.dat.gz
RUN gunzip DionaeaFR-master/DionaeaFR/static/GeoIP.dat.gz



# Setup apt
RUN echo "deb http://ppa.launchpad.net/honeynet/nightly/ubuntu trusty main" >> /etc/apt/sources.list
RUN echo "deb-src http://ppa.launchpad.net/honeynet/nightly/ubuntu trusty main" >> /etc/apt/sources.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys FC8C70BBE667E4FB0F42916511C832A6A6131AE4
RUN apt-get update -y
RUN apt-get dist-upgrade -y
ENV DEBIAN_FRONTEND noninteractive

# Install packages 
RUN apt-get install -y supervisor dionaea-phibo

# Setup user, groups and configs
RUN addgroup --gid 2000 tpot 
RUN adduser --system --no-create-home --shell /bin/bash --uid 2000 --disabled-password --disabled-login --gid 2000 tpot
RUN mkdir -p /data/dionaea/log /data/dionaea/bistreams /data/dionaea/binaries /data/dionaea/rtp /data/dionaea/wwwroot
RUN chmod 760 -R /data && chown tpot:tpot -R /data
ADD conf/dionaea.conf /etc/dionaea/
ADD conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD conf/settings.py /DionaeaFR-master/DionaeaFR/settings.py
RUN mkdir /var/run/dionaeafr/

# Clean up 
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Start dionaea
CMD ["/usr/bin/supervisord"]

