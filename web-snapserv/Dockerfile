FROM quay.io/snapserv/hugo:1.0.0 AS hugo
FROM quay.io/snapserv/nginx:1.0.1

COPY --from=hugo /var/www/html /var/www/html
RUN chown -R www-data:www-data /var/www/html
