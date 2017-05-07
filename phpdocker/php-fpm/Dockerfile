# Extends phpdockerio/php56-cli
FROM phpdockerio/php56-fpm:latest

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
    php5-intl \
    php5-gd \
    php5-xsl \
    php5-gd \
    php5-memcached \
    php5-mysql \
    php5-redis \
    php5-xdebug \
    php5-xmlrpc \
    && apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

WORKDIR "/application"
