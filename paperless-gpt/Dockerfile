# =============================================================================
# Home Assistant Add-on: Paperless-GPT
# =============================================================================
# This Dockerfile uses a multi-stage approach:
# Stage 1: Pull the upstream paperless-gpt binary and assets
# Stage 2: Place them into the HA base image with bashio integration
# =============================================================================

ARG BUILD_FROM=ghcr.io/home-assistant/base:latest

# -----------------------------------------------------------------------------
# Stage 1: Extract paperless-gpt from the upstream image
# -----------------------------------------------------------------------------
FROM icereed/paperless-gpt:latest AS upstream

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

# Ensure binary is executable
RUN chmod +x /app/paperless-gpt /app/entrypoint.sh

# Copy run script (HA integration layer)
COPY run.sh /
RUN chmod a+x /run.sh

# Copy root filesystem
COPY rootfs /

WORKDIR /app

CMD [ "/run.sh" ]
