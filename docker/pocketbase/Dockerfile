# syntax=docker/dockerfile:1
FROM alpine:3.21

ARG PB_VERSION=0.36.6
ARG TARGETARCH

RUN apk add --no-cache \
    ca-certificates \
    unzip \
    wget

# Download PocketBase for the target architecture
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) PB_ARCH="linux_amd64" ;; \
        arm64) PB_ARCH="linux_arm64" ;; \
        *) echo "Unsupported arch: ${TARGETARCH}" && exit 1 ;; \
    esac; \
    wget -qO /tmp/pocketbase.zip \
        "https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_${PB_ARCH}.zip" && \
    unzip /tmp/pocketbase.zip pocketbase -d /pb && \
    rm /tmp/pocketbase.zip && \
    chmod +x /pb/pocketbase

VOLUME ["/pb/pb_data"]

EXPOSE 8090

ENTRYPOINT ["/pb/pocketbase", "serve"]
CMD ["--http=0.0.0.0:8090", "--dir=/pb/pb_data", "--encryptionEnv=PB_ENCRYPTION_KEY"]
