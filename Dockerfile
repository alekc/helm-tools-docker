FROM alpine:3.20

RUN apk add --no-cache helm gnupg expect curl ca-certificates

ARG VALS_VERSION=0.46.0
ARG TARGETARCH

# checksums.txt from https://github.com/helmfile/vals/releases/tag/v${VALS_VERSION}
RUN set -eu; \
    case "${TARGETARCH}" in \
      amd64) VALS_SHA256="42d2f672dc98b040b8179e87b1c3474418003b95a938ba3bbe13310e5e82847c" ;; \
      arm64) VALS_SHA256="a5b5470de20ade57944cdce7393ba9b5be57ded359162e41ec0ea0920c114f6f" ;; \
      *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -sSL -o /tmp/vals.tar.gz \
      "https://github.com/helmfile/vals/releases/download/v${VALS_VERSION}/vals_${VALS_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    echo "${VALS_SHA256}  /tmp/vals.tar.gz" | sha256sum -c; \
    tar -xzf /tmp/vals.tar.gz -C /usr/local/bin vals; \
    rm /tmp/vals.tar.gz

ENTRYPOINT []
