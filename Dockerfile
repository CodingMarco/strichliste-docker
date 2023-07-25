FROM alpine:3.18 as release

RUN apk --no-cache add ca-certificates \
  && apk --no-cache add \
    curl \
    tar

RUN mkdir /source
WORKDIR /source
RUN curl -Lo strichliste.tar.gz https://github.com/strichliste/strichliste/releases/download/v1.8.2/strichliste-v1.8.2.tar.gz
RUN tar -xf strichliste.tar.gz
RUN rm -f strichliste.tar.gz


FROM alpine:3.18

RUN apk --no-cache add ca-certificates \
  && apk --no-cache add \
    curl \
    php7 \
    php7-ctype \
    php7-tokenizer \
    php7-iconv \
    php7-mbstring \
    php7-xml \
    php7-json \
    php7-dom \
    php7-pdo_mysql \
    php7-fpm \
    nginx \
    bash \
    mysql-client \
    yarn

COPY --from=release /source source

COPY ./entrypoint.sh /source/entrypoint.sh
RUN chmod +x /source/entrypoint.sh

RUN adduser -u 82 -D -S -G www-data www-data
RUN chown -R www-data:www-data /source
RUN chown -R www-data:www-data /var/lib/nginx
RUN chown -R www-data:www-data /var/tmp/nginx
RUN chown -R www-data:www-data /var/log/nginx
RUN chown -R www-data:www-data /var/log/php7

USER www-data

COPY ./config/php-fpm.conf /etc/php7/php-fpm.conf
COPY ./config/www.conf /etc/php7/php-fpm.d/www.conf
COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./config/default.conf /etc/nginx/conf.d/default.conf

VOLUME /source/var

WORKDIR /source/public
EXPOSE 8080

ENTRYPOINT ["/source/entrypoint.sh"]
CMD nginx && php-fpm7
