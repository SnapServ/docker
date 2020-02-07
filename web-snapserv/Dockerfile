FROM quay.io/snapserv/hugo:1.0.0@sha256:778172c4477e0949b97058e34611290e99d217c1fc5af6d3e70d0053b61df872 AS hugo
FROM quay.io/snapserv/nginx:1.0.3@sha256:50281c730132ee3e206192162caaf743eb6ef476a978ea632eec375d92178945

COPY --from=hugo /var/www/html /var/www/html
RUN chown -R www-data:www-data /var/www/html
