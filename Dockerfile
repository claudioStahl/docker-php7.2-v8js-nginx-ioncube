FROM phpv8/php-v8

ENV PHP_RUN_DIR=/run/php \
    PHP_LOG_DIR=/var/log/php \
    PHP_CONF_DIR=/etc/php/7.2 \
    PHP_DATA_DIR=/var/lib/php \
    LANG=${OS_LOCALE} \
    LANGUAGE=${OS_LOCALE} \
    LC_ALL=${OS_LOCALE} \
    NGINX_CONF_DIR=/etc/nginx

COPY ./supervisord.conf /etc/supervisor/conf.d/
COPY ./app /var/www/app/

RUN apt-get update -y && \
	apt-get upgrade -y && \
	apt-get install -y nginx \
	php7.2-mysql \
    php7.2-mbstring \
    php7.2-json \
    php7.2-dev \
    php7.2-odbc \
    php7.2-opcache \
    php7.2-xml \
    php7.2-xsl \
    php7.2-gd \
    php7.2-zip \
    php7.2-curl \
    supervisor \
    && mkdir -p /var/log/supervisor

COPY ./configs/php-fpm.conf ${PHP_CONF_DIR}/fpm/php-fpm.conf
COPY ./configs/php.ini ${PHP_CONF_DIR}/fpm/conf.d/custom.ini
COPY ./configs/nginx.conf ${NGINX_CONF_DIR}/nginx.conf
COPY ./configs/app.conf ${NGINX_CONF_DIR}/sites-enabled/app.conf
COPY ./configs/www.conf /etc/php/7.2/fpm/pool.d/www.conf

RUN sed -i "s~PHP_RUN_DIR~${PHP_RUN_DIR}~g" ${PHP_CONF_DIR}/fpm/php-fpm.conf \
    && sed -i "s~PHP_LOG_DIR~${PHP_LOG_DIR}~g" ${PHP_CONF_DIR}/fpm/php-fpm.conf \
    && chown www-data:www-data ${PHP_DATA_DIR} -Rf

ADD http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz /tmp/
RUN tar xvfz /tmp/ioncube_loaders_lin_x86-64.tar.gz \
    && mkdir -p /usr/local/ioncube/  \
    && cp ioncube/ioncube_loader_lin_7.2.so /usr/local/ioncube/ \
    && mkdir -p /etc/php/7.2/fpm/conf.d/

COPY ./00-ioncube.ini /etc/php/7.2/fpm/conf.d/00-ioncube.ini

WORKDIR /var/www/app/

EXPOSE 80 443

VOLUME ["${PHP_RUN_DIR}", "${PHP_DATA_DIR}"]
CMD ["/usr/bin/supervisord"]