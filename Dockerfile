FROM php:8.1-fpm-alpine

WORKDIR /var/www/html

ARG UID=1000
ARG GID=$UID

# https://github.com/gliderlabs/docker-alpine/issues/307#issuecomment-317469410
RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories

# install supervisor shadow nginx
RUN apk add --no-cache supervisor shadow nginx
RUN groupmod -g $GID www-data
RUN usermod -u $UID www-data

# install extentions
RUN apk add --no-cache ${PHPIZE_DEPS}
RUN docker-php-ext-install sockets
RUN pecl install -D 'enable-sockets="no" enable-openssl="no" enable-http2="no" enable-mysqlnd="no" enable-swoole-json="no" enable-swoole-curl="no" enable-cares="no"' swoole
RUN pecl install redis
RUN docker-php-ext-enable swoole redis
RUN apk del ${PHPIZE_DEPS}

RUN apk add --no-cache icu-dev postgresql-dev
RUN docker-php-ext-install pdo_pgsql pgsql intl pcntl

# copy configs
COPY --chown=www-data:www-data ./docker/supervisor /etc/
COPY --chown=www-data:www-data ./docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY --chown=www-data:www-data ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --chown=www-data:www-data ./docker/nginx/swoole.conf /etc/nginx/conf.d/swoole.conf
COPY --chown=www-data:www-data ./docker/php/php.ini /usr/local/etc/php/php.ini
COPY --chown=www-data:www-data ./docker/php/www.conf /usr/local/etc/php-fpm.d/www.conf
RUN chown -R www-data:www-data /var/lib/nginx /var/log/nginx  /home/www-data/

# cronjobs
RUN apk add --no-cache dcron libcap && chown www-data:www-data /usr/sbin/crond && setcap cap_setgid=ep /usr/sbin/crond
COPY --chown=www-data:www-data ./docker/cronjobs /etc/crontabs/www-data

#composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

USER www-data
COPY --chown=www-data:www-data ./src/composer.lock ./src/composer.json ./
RUN COMPOSER_AUTH="$COMPOSER_AUTH" composer install --no-scripts --prefer-dist --no-interaction --no-progress --optimize-autoloader
COPY --chown=www-data:www-data ./src $PWD
RUN composer run-script post-autoload-dump

CMD ["/usr/bin/supervisord", "-nc", "/etc/supervisord.conf"]
