#!/usr/bin/with-contenv bashio
# ============================================================================
# Home Assistant Add-on: Paperless-GPT
# run.sh — Bridge between HA config (options.json) and paperless-gpt env vars
# ============================================================================

set -euo pipefail

bashio::log.info "Starting Paperless-GPT Home Assistant Add-on..."

# ----------------------------------------------------------------------------
# Helper: set env var only if the bashio config value is non-empty
# ----------------------------------------------------------------------------
set_env_if_set() {
    local key="$1"
    local val
    val="$(bashio::config "${key}")"
    if bashio::var.has_value "${val}"; then
        export "${key^^}=${val}"
        bashio::log.debug "  ${key^^}=${val}"
    fi
}

# ----------------------------------------------------------------------------
# Helper: set env var from a config key with a different env var name
# ----------------------------------------------------------------------------
set_env_mapped() {
    local config_key="$1"
    local env_name="$2"
    local val
    val="$(bashio::config "${config_key}")"
    if bashio::var.has_value "${val}"; then
        export "${env_name}=${val}"
        bashio::log.debug "  ${env_name}=${val}"
    fi
}

# ----------------------------------------------------------------------------
# Paperless-NGX connection
# ----------------------------------------------------------------------------
set_env_mapped "paperless_base_url" "PAPERLESS_BASE_URL"
set_env_mapped "paperless_api_token" "PAPERLESS_API_TOKEN"
set_env_mapped "paperless_public_url" "PAPERLESS_PUBLIC_URL"

# ----------------------------------------------------------------------------
# LLM Configuration
# ----------------------------------------------------------------------------
set_env_mapped "llm_provider" "LLM_PROVIDER"
set_env_mapped "llm_model" "LLM_MODEL"
set_env_mapped "openai_api_key" "OPENAI_API_KEY"
set_env_mapped "openai_base_url" "OPENAI_BASE_URL"
set_env_mapped "openai_api_type" "OPENAI_API_TYPE"
set_env_mapped "mistral_api_key" "MISTRAL_API_KEY"
set_env_mapped "anthropic_api_key" "ANTHROPIC_API_KEY"
set_env_mapped "googleai_api_key" "GOOGLEAI_API_KEY"
set_env_mapped "ollama_host" "OLLAMA_HOST"
set_env_mapped "ollama_context_length" "OLLAMA_CONTEXT_LENGTH"
set_env_mapped "ollama_headers" "OLLAMA_HEADERS"
set_env_mapped "token_limit" "TOKEN_LIMIT"
set_env_mapped "llm_language" "LLM_LANGUAGE"

# ----------------------------------------------------------------------------
# Optional: extra request fields for OpenAI-compatible APIs
# paperless-gpt cannot pass provider-specific parameters (e.g. Scaleway's
# reasoning_effort). If openai_extra_body is set, a local proxy adds these
# fields to every chat request for llm_model and forwards everything else
# unchanged (vision/OCR model included).
# ----------------------------------------------------------------------------
if bashio::config.has_value "openai_extra_body" \
    && [ "$(bashio::config 'llm_provider')" = "openai" ]; then
    extra_body="$(bashio::config 'openai_extra_body')"
    if ! printf '%s' "${extra_body}" | jq -e 'type == "object" and length > 0' >/dev/null 2>&1; then
        bashio::log.error "openai_extra_body must be a JSON object, e.g. {\"reasoning_effort\":\"none\"}"
        bashio::exit.nok
    fi
    export PROXY_UPSTREAM="${OPENAI_BASE_URL:-https://api.openai.com/v1}"
    export PROXY_EXTRA_BODY="${extra_body}"
    export PROXY_MODELS="$(bashio::config 'llm_model')"
    export PROXY_LISTEN="127.0.0.1:18080"
    (
        while true; do
            /usr/local/bin/llm-proxy || true
            bashio::log.warning "llm-proxy stopped, restarting in 2 s"
            sleep 2
        done
    ) &
    export OPENAI_BASE_URL="http://127.0.0.1:18080"
    bashio::log.info "openai_extra_body active for ${PROXY_MODELS}: ${extra_body}"
    sleep 1
fi

# ----------------------------------------------------------------------------
# Tags
# ----------------------------------------------------------------------------
set_env_mapped "manual_tag" "MANUAL_TAG"
set_env_mapped "auto_tag" "AUTO_TAG"
set_env_mapped "fail_tag" "FAIL_TAG"

# ----------------------------------------------------------------------------
# OCR Configuration
# ----------------------------------------------------------------------------
set_env_mapped "ocr_provider" "OCR_PROVIDER"
set_env_mapped "vision_llm_provider" "VISION_LLM_PROVIDER"
set_env_mapped "vision_llm_model" "VISION_LLM_MODEL"
set_env_mapped "ocr_process_mode" "OCR_PROCESS_MODE"
set_env_mapped "pdf_skip_existing_ocr" "PDF_SKIP_EXISTING_OCR"
set_env_mapped "auto_ocr_tag" "AUTO_OCR_TAG"
set_env_mapped "ocr_limit_pages" "OCR_LIMIT_PAGES"
set_env_mapped "ocr_max_retries" "OCR_MAX_RETRIES"

# ----------------------------------------------------------------------------
# Enhanced OCR Features
# ----------------------------------------------------------------------------
set_env_mapped "create_local_hocr" "CREATE_LOCAL_HOCR"
set_env_mapped "local_hocr_path" "LOCAL_HOCR_PATH"
set_env_mapped "create_local_pdf" "CREATE_LOCAL_PDF"
set_env_mapped "local_pdf_path" "LOCAL_PDF_PATH"
set_env_mapped "pdf_upload" "PDF_UPLOAD"
set_env_mapped "pdf_replace" "PDF_REPLACE"
set_env_mapped "pdf_copy_metadata" "PDF_COPY_METADATA"
set_env_mapped "pdf_ocr_tagging" "PDF_OCR_TAGGING"
set_env_mapped "pdf_ocr_complete_tag" "PDF_OCR_COMPLETE_TAG"

# ----------------------------------------------------------------------------
# Google Document AI
# ----------------------------------------------------------------------------
set_env_mapped "google_project_id" "GOOGLE_PROJECT_ID"
set_env_mapped "google_location" "GOOGLE_LOCATION"
set_env_mapped "google_processor_id" "GOOGLE_PROCESSOR_ID"
set_env_mapped "google_application_credentials" "GOOGLE_APPLICATION_CREDENTIALS"

# ----------------------------------------------------------------------------
# Azure Document Intelligence
# ----------------------------------------------------------------------------
set_env_mapped "azure_docai_endpoint" "AZURE_DOCAI_ENDPOINT"
set_env_mapped "azure_docai_key" "AZURE_DOCAI_KEY"
set_env_mapped "azure_docai_model_id" "AZURE_DOCAI_MODEL_ID"
set_env_mapped "azure_docai_timeout_seconds" "AZURE_DOCAI_TIMEOUT_SECONDS"
set_env_mapped "azure_docai_output_content_format" "AZURE_DOCAI_OUTPUT_CONTENT_FORMAT"

# ----------------------------------------------------------------------------
# Docling Server
# ----------------------------------------------------------------------------
set_env_mapped "docling_url" "DOCLING_URL"
set_env_mapped "docling_image_export_mode" "DOCLING_IMAGE_EXPORT_MODE"
set_env_mapped "docling_ocr_pipeline" "DOCLING_OCR_PIPELINE"
set_env_mapped "docling_ocr_engine" "DOCLING_OCR_ENGINE"

# ----------------------------------------------------------------------------
# General
# ----------------------------------------------------------------------------
set_env_mapped "log_level" "LOG_LEVEL"
set_env_mapped "listen_interface" "LISTEN_INTERFACE"
set_env_mapped "puid" "PUID"
set_env_mapped "pgid" "PGID"

# ----------------------------------------------------------------------------
# Persistent storage
# paperless-gpt works with paths relative to /app: prompts/, config/, db/.
# Inside the container they are lost whenever the container is re-created
# (add-on update, HA restart, Supervisor restart). Link them to persistent
# add-on storage:
#   /app/prompts -> /config/prompts   (addon_config: editable via Samba /
#                                      Studio Code under addon_configs/)
#   /app/config  -> /data/config      (settings.json, e.g. custom fields)
#   /app/db      -> /data/db          (modification history / undo)
# Missing prompt files are copied from /app/default_prompts by paperless-gpt
# itself (loadTemplates), existing files are never overwritten.
# ----------------------------------------------------------------------------
mkdir -p /data/hocr /data/pdf

link_persistent() {
    local name="$1"
    local target="$2"
    mkdir -p "${target}"
    if [ -d "/app/${name}" ] && [ ! -L "/app/${name}" ]; then
        # One-time migration of content created inside this container
        if [ -z "$(ls -A "${target}" 2>/dev/null)" ]; then
            cp -a "/app/${name}/." "${target}/" 2>/dev/null || true
        fi
        rm -rf "/app/${name}"
    fi
    ln -sfn "${target}" "/app/${name}"
}

# One-time migration: prompts from older add-on versions lived in /data/prompts
if [ -z "$(ls -A /config/prompts 2>/dev/null)" ] && [ -n "$(ls -A /data/prompts 2>/dev/null)" ]; then
    mkdir -p /config/prompts
    cp -a /data/prompts/. /config/prompts/ 2>/dev/null || true
    rm -f /config/prompts/title.txt
    bashio::log.info "Migrated prompts from /data/prompts to /config/prompts"
fi

link_persistent prompts /config/prompts
link_persistent config  /data/config
link_persistent db      /data/db

# paperless-gpt runs as PUID:PGID; entrypoint.sh only chowns /app and does not
# follow symlinks, so hand the persistent targets to that user explicitly.
chown -R "${PUID:-10001}:${PGID:-10001}" /config/prompts /data/config /data/db

bashio::log.info "Prompts: /config/prompts (addon_configs), settings and db: /data"

# ----------------------------------------------------------------------------
# Validate required settings
# ----------------------------------------------------------------------------
if ! bashio::config.has_value "paperless_api_token"; then
    bashio::log.error "paperless_api_token is required! Set it in the add-on configuration."
    bashio::exit.nok
fi

if ! bashio::config.has_value "llm_provider"; then
    bashio::log.error "llm_provider is required! Set it in the add-on configuration."
    bashio::exit.nok
fi

bashio::log.info "Configuration loaded successfully."
bashio::log.info "  LLM Provider: $(bashio::config 'llm_provider')"
bashio::log.info "  LLM Model: $(bashio::config 'llm_model')"
bashio::log.info "  OCR Provider: $(bashio::config 'ocr_provider')"
bashio::log.info "  Paperless URL: $(bashio::config 'paperless_base_url')"

# ----------------------------------------------------------------------------
# Start paperless-gpt
# ----------------------------------------------------------------------------
bashio::log.info "Starting paperless-gpt..."

cd /app
exec su-exec root ./entrypoint.sh
