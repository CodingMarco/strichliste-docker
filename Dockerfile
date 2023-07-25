FROM php:8.2-fpm-alpine

RUN apk --no-cache add ca-certificates \
  && apk --no-cache add \
    curl \
    nginx \
    bash \
    mysql-client \
    yarn \
    tar

RUN docker-php-ext-install mysqli pdo pdo_mysql

RUN mkdir /source
WORKDIR /source
RUN curl -Lo strichliste.tar.gz https://github.com/strichliste/strichliste/releases/download/v1.8.2/strichliste-v1.8.2.tar.gz
RUN tar -xf strichliste.tar.gz
RUN rm -f strichliste.tar.gz

COPY ./entrypoint.sh /source/entrypoint.sh
RUN chmod +x /source/entrypoint.sh

RUN chown -R www-data:www-data /source
RUN chown -R www-data:www-data /var/lib/nginx
RUN chown -R www-data:www-data /var/log/nginx
RUN chown -R www-data:www-data /usr/local/var/log

USER www-data

COPY ./config/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY ./config/www.conf /usr/local/etc/php-fpm.d/docker.conf
COPY ./config/nginx.conf /etc/nginx/nginx.conf

VOLUME /source/var

WORKDIR /source/public
EXPOSE 8080

ENTRYPOINT ["/source/entrypoint.sh"]
CMD nginx && php-fpm
