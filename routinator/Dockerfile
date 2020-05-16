FROM rust:1.43@sha256:65841f86b166ca1064d522d8eedc8efbeee8e007d984918d9f54d57d86c3572e AS builder

# renovate: datasource=crate depName=routinator
ENV ROUTINATOR_VERSION="0.6.4"

RUN true \
    # Install build toolchain
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        musl-tools \
    && rustup target add x86_64-unknown-linux-musl \
    # Compile statically linked binary
    && cargo install \
        --version="${ROUTINATOR_VERSION}" \
        --root=/opt/routinator \
        --target=x86_64-unknown-linux-musl \
        routinator \
    && true

FROM quay.io/snapserv/base-alpine:1.1.15@sha256:34f27840f7c7aa20a7b78ea2a9167daa8a690b19c71e40547b68216ba5266318

RUN true \
    # Install runtime dependencies
    && apk add --no-cache \
        rsync \
    # Prepare container runtime environment
    && ctutil account -u 2000 -g 2000 routinator \
    && ctutil directory -u routinator -g routinator -m 0700 \
        /cts/routinator/persistent \
    && true

COPY --from=builder /opt/routinator/bin/routinator /usr/local/bin/routinator
COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

USER 2000
EXPOSE 3323/tcp 9556/tcp
VOLUME [ "/cts/routinator/persistent" ]

ENTRYPOINT [ "/docker-entrypoint.sh" ]
