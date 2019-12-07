FROM quay.io/snapserv/hugo:1.0.0@sha256:778172c4477e0949b97058e34611290e99d217c1fc5af6d3e70d0053b61df872 AS hugo
FROM quay.io/snapserv/nginx:1.0.2@sha256:aa13d7fcca2389ca30ff4765ea22b7f82a12ee92a157d069b7a4045dfa042cd2

COPY --from=hugo /var/www/html /var/www/html
RUN chown -R www-data:www-data /var/www/html
