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
    locales \
    && apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && printf 'en_AU.UTF-8 UTF-8\n' >> /etc/locale.gen \
    && locale-gen

WORKDIR "/application"
