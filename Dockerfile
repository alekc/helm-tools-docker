FROM alpine:3.24

RUN apk add --no-cache helm gnupg expect curl ca-certificates aws-cli

ARG VALS_VERSION=0.51.1
ARG TARGETARCH

# checksums.txt from https://github.com/helmfile/vals/releases/tag/v${VALS_VERSION}
RUN set -eu; \
    case "${TARGETARCH}" in \
      amd64) VALS_SHA256="2f6ca3eb403ce35647c0ca9bca9b2b3535197b28f82d3a1919b2ccc4218a9c03" ;; \
      arm64) VALS_SHA256="a61ca3407ec60dde9ea61442addb5c99a46f1925f0b35e295da05da94ce191b6" ;; \
      *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -sSL -o /tmp/vals.tar.gz \
      "https://github.com/helmfile/vals/releases/download/v${VALS_VERSION}/vals_${VALS_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    echo "${VALS_SHA256}  /tmp/vals.tar.gz" | sha256sum -c; \
    tar -xzf /tmp/vals.tar.gz -C /usr/local/bin vals; \
    rm /tmp/vals.tar.gz

# gpg-agent's passphrase prompt otherwise needs a tty; loopback pinentry
# lets --passphrase-file/--passphrase work in a CI job. Baked in here so
# no job needs gpgconf --reload, nothing's running yet to reload.
RUN mkdir -p -m 700 /root/.gnupg && \
    echo "allow-loopback-pinentry" > /root/.gnupg/gpg-agent.conf && \
    chmod 600 /root/.gnupg/gpg-agent.conf

ENTRYPOINT []
