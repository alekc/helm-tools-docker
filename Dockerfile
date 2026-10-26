FROM alpine:3.24

RUN apk add --no-cache helm gnupg expect curl ca-certificates aws-cli

ARG VALS_VERSION=0.50.0
ARG TARGETARCH

# checksums.txt from https://github.com/helmfile/vals/releases/tag/v${VALS_VERSION}
RUN set -eu; \
    case "${TARGETARCH}" in \
      amd64) VALS_SHA256="4cb1664b1e0aa49481cb05fabe2c52d4944dcaab31c4805924b668ae9f54c379" ;; \
      arm64) VALS_SHA256="1e7c4d2b187391c7ef33be69c548cc6624152e75816c9d458e52a462e409542f" ;; \
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
