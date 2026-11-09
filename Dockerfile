FROM alpine:3.24

RUN apk add --no-cache helm gnupg expect curl ca-certificates aws-cli

ARG VALS_VERSION=0.51.0
ARG TARGETARCH

# checksums.txt from https://github.com/helmfile/vals/releases/tag/v${VALS_VERSION}
RUN set -eu; \
    case "${TARGETARCH}" in \
      amd64) VALS_SHA256="189de2b4a00e7abd6bf7626010f0a985e615006a6575b249915fb80791ff8f2f" ;; \
      arm64) VALS_SHA256="9315a0263bd18ba2e625c8259bc50b94881f57140464fddc9507e1c799aa61c7" ;; \
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
