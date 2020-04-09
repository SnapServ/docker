FROM golang:1.14-alpine@sha256:b3845270d316263dbca71b2abc7383b2cb8e672acf08588f8da710346099b061 AS builder

RUN true \
    && apk add --no-cache \
    gcc \
    musl-dev \
    && true

WORKDIR /src
COPY ctutil/go.mod ctutil/go.sum /src/
RUN go mod download

COPY ctutil .
RUN go build -ldflags="-s -w" -o /bin/ctutil .

FROM alpine:3.11.5@sha256:cb8a924afdf0229ef7515d9e5b3024e23b3eb03ddbba287f4a19c6ac90b8d221
SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]

RUN true \
    # Use APK repositories with HTTPS
    && echo "https://alpine.global.ssl.fastly.net/alpine/v$(cut -d'.' -f1,2 /etc/alpine-release)/main" > /etc/apk/repositories \
    && echo "https://alpine.global.ssl.fastly.net/alpine/v$(cut -d'.' -f1,2 /etc/alpine-release)/community" >> /etc/apk/repositories \
    # Install CA certificates and timezone data
    && apk add --no-cache --virtual .base \
    ca-certificates \
    tzdata \
    # Remove unnecessary accounts and groups
    && sed -i -r '/^(root|nobody)/!d' /etc/passwd \
    && sed -i -r '/^(root|nobody)/!d' /etc/shadow \
    && sed -i -r '/^(root|nobody|nogroup)/!d' /etc/group \
    # Disable interactive login shell for all accounts
    && sed -i -r 's~^(.*):[^:]*$~\1:/sbin/nologin~' /etc/passwd \
    # Disable password login for all accounts
    && while IFS=':' read -r user _; do passwd -l "${user}" || true; done < /etc/passwd \
    # Remove world-writeable permissions except /tmp
    && find / -xdev -type d -perm +0002 ! -path '/tmp' -exec chmod o-w {} + \
    && find / -xdev -type f -perm +0002 -exec chmod o-w {} + \
    # Remove suid/sgid files
    && find /bin /etc /lib /sbin /usr -xdev -type f -a \( -perm +4000 -o -perm +2000 \) -delete \
    # Remove unused system configs
    && rm -rf \
    /etc/fstab \
    /etc/modprobe.d \
    /etc/modules \
    /etc/modules-load.d \
    /etc/sysctl.conf \
    /etc/sysctl.d \
    # Remove unused user configs and scripts
    && rm -rf \
    /etc/conf.d \
    /etc/crontabs \
    /etc/init.d \
    /etc/inittab \
    /etc/logrotate.d \
    /etc/periodic \
    /var/spool/cron \
    && true

COPY --from=builder /bin/ctutil /usr/local/bin/ctutil
COPY rootfs /

RUN true \
    # Prepare common directory for persistent storage
    && ctutil directory -u root -g root -m 0755 /cts \
    # Relocate /var/run and /var/tmp to /run and /tmp
    && ctutil relocate /var/run /run \
    && ctutil relocate /var/tmp /tmp \
    && true
