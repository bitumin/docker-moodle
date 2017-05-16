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
    clamav \
    clamav-daemon \
    clamav-freshclam \
    && apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*; \
    printf 'en_AU.UTF-8 UTF-8\n' >> /etc/locale.gen \
    && locale-gen; \
    mkdir -p /var/run/clamav \
    && chown clamav:clamav /var/run/clamav \
    && chmod 750 /var/run/clamav; \
    mkdir -p /var/lib/clamav \
    && chown -R clamav:clamav /var/lib/clamav; \
    adduser www-data clamav \
    && adduser clamav www-data;

WORKDIR "/application"

CMD freshclam -d \
    & /usr/sbin/php5-fpm -F -O 2>&1 | sed -u 's,.*: \"\(.*\)$,\1,'| sed -u 's,"$,,' 1>&1
