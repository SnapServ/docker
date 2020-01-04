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

COPY --from=builder /bin/scp /usr/local/bin/scp
COPY rootfs /

RUN true \
    # Relocate /var/run and /var/tmp to /run and /tmp
    && scp relocate /var/run /run \
    && scp relocate /var/tmp /tmp \
    && true
