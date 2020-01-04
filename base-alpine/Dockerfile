FROM golang:1.13-alpine@sha256:0991060a1447cf648bab7f6bb60335d1243930e38420bee8fec3db1267b84cfa AS builder

RUN true \
    && apk add --no-cache \
    gcc \
    musl-dev \
    && true

WORKDIR /src
COPY scp/go.mod scp/go.sum /src/
RUN go mod download

COPY scp .
RUN go build -ldflags="-s -w" -o /bin/scp .

FROM alpine:3.11.2@sha256:3983cc12fb9dc20a009340149e382a18de6a8261b0ac0e8f5fcdf11f8dd5937e
SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]

RUN true \
    && apk add --no-cache --virtual .base \
    ca-certificates \
    tzdata \
    && true

COPY --from=builder /bin/scp /usr/local/bin/scp
COPY rootfs /
