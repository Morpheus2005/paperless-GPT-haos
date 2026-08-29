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
# Ensure data directories exist
# ----------------------------------------------------------------------------
mkdir -p /data/hocr /data/pdf /data/config /data/prompts

# Copy default prompts if no custom prompts exist
if [ ! -f /data/prompts/title.txt ]; then
    if [ -d /app/default_prompts ]; then
        cp -r /app/default_prompts/* /data/prompts/ 2>/dev/null || true
        bashio::log.info "Default prompts copied to /data/prompts/"
    fi
fi

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
