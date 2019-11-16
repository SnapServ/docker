FROM quay.io/snapserv/hugo:1.0.0@sha256:778172c4477e0949b97058e34611290e99d217c1fc5af6d3e70d0053b61df872 AS hugo
FROM quay.io/snapserv/nginx:1.0.1@sha256:de33c14d27e347bd8b87590bedbe83267442f63c872a2294195ae328e7cfdf9e

COPY --from=hugo /var/www/html /var/www/html
RUN chown -R www-data:www-data /var/www/html
