FROM ubuntu:bionic
MAINTAINER Tillmann Heidsieck <theidsieck@leenox.de>
ARG NEXTCLOUD_VERSION=15.0.4
EXPOSE 80

#DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -yqq && \
RUN apt-get update 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yqq \
	bzip2 \
	curl \
	cron \
	gnupg \
	php-apcu \
	php-cli \
	php-curl \
	php-dompdf \
	php-fpm \
	php-gd \
	php-gmp \
	php-imagick \
	php-intl \
	php-json \
	php-mbstring \
	php-mysql \
	php-pgsql \
	php-sqlite3 \
	php-redis \
	php-xmlrpc \
	php-xml \
	php-zip \
	nginx-extras \
	ssmtp \
	supervisor

RUN ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
	dpkg-reconfigure --frontend noninteractive tzdata

RUN useradd -s /bin/bash -r -M -d /srv/www nextcloud

COPY nextcloud.asc /nextcloud.asc
COPY supervisord.conf /etc/
COPY crontab /etc/
COPY nginx.conf /etc/nginx/
COPY occ /usr/bin/
COPY run.sh /usr/bin/
COPY www.conf /etc/php/7.2/fpm/pool.d/
COPY php.ini /etc/php/7.2/fpm/

RUN mkdir -p /run/php && chown nextcloud.nextcloud /run/php

RUN curl https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2 > /nextcloud.tar.bz2
RUN curl https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2.asc > /nextcloud.tar.bz2.asc

RUN gpg --import /nextcloud.asc
RUN gpg --verify /nextcloud.tar.bz2.asc
RUN tar -xjf nextcloud.tar.bz2 && mv nextcloud /srv/www && chown -R nextcloud.nextcloud /srv/www

ENTRYPOINT ["/usr/bin/run.sh"]
