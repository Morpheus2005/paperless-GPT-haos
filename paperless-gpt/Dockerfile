# =============================================================================
# Home Assistant Add-on: Paperless-GPT
# =============================================================================
# This Dockerfile uses a multi-stage approach:
# Stage 1: Pull the upstream paperless-gpt binary and assets
# Stage 2: Place them into the HA base image with bashio integration
# =============================================================================

ARG BUILD_FROM=ghcr.io/home-assistant/base:latest
# Upstream paperless-gpt version. Pinned on purpose: prompt templates, template
# variables and response parsers are verified against this version. Bump it
# deliberately and re-check the custom prompts after an upgrade.
ARG UPSTREAM_VERSION=v0.28.0

# -----------------------------------------------------------------------------
# Stage 1: Extract paperless-gpt from the upstream image
# -----------------------------------------------------------------------------
FROM icereed/paperless-gpt:${UPSTREAM_VERSION} AS upstream

# -----------------------------------------------------------------------------
# Stage 1b: Build llm-proxy (adds extra request fields such as
# reasoning_effort for OpenAI-compatible APIs, see proxy/main.go)
# -----------------------------------------------------------------------------
FROM golang:1.23-alpine AS proxybuild
WORKDIR /src
COPY proxy/ .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /llm-proxy .

# -----------------------------------------------------------------------------
# Stage 2: Home Assistant base image with paperless-gpt
# -----------------------------------------------------------------------------
FROM $BUILD_FROM

# Install runtime dependencies
RUN \
    apk add --no-cache \
        bash \
        curl \
        jq \
        ca-certificates \
        su-exec

# bashio is already included in the HA base image
# If not present (non-HA base), install it
RUN \
    if ! command -v bashio &>/dev/null; then \
        curl -sSLf -o /usr/bin/bashio \
            "https://github.com/hassio-addons/bashio/releases/latest/download/bashio" \
        && chmod a+x /usr/bin/bashio; \
    fi

# Copy paperless-gpt binary from upstream
COPY --from=upstream /app/paperless-gpt /app/paperless-gpt
COPY --from=upstream /app/entrypoint.sh /app/entrypoint.sh
COPY --from=upstream /app/default_prompts/ /app/default_prompts/

# llm-proxy (optional, started by run.sh only if openai_extra_body is set)
COPY --from=proxybuild /llm-proxy /usr/local/bin/llm-proxy

# Ensure binaries are executable
RUN chmod +x /app/paperless-gpt /app/entrypoint.sh /usr/local/bin/llm-proxy

# Copy run script (HA integration layer)
COPY run.sh /
RUN chmod a+x /run.sh

# Copy root filesystem
COPY rootfs /

WORKDIR /app

CMD [ "/run.sh" ]
