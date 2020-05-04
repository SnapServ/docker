FROM quay.io/snapserv/hugo:1.0.2@sha256:517286e482cfdf44cfe12ca3b869d70561f859d11e5f949bd902aad66e1dd471 AS builder

COPY repository /usr/local/src
USER root
RUN hugo -s /usr/local/src -d /var/www/hugo

FROM quay.io/snapserv/nginx:1.0.4@sha256:71e85a882dda062535cbbf959a014d1a9dc39c8e3a62cfb309abd7cb9425c3f9

COPY --from=builder /var/www/hugo /var/www/html
