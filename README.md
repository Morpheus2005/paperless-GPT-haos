# Paperless-GPT Home Assistant Add-on

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FYOUR_GITHUB_USERNAME%2Fpaperless-gpt-haos)

AI-powered document titles, tags, and OCR for [Paperless-NGX](https://github.com/paperless-ngx/paperless-ngx) — directly in Home Assistant.

Uses [paperless-gpt](https://github.com/icereed/paperless-gpt) by [Icereed](https://github.com/icereed).

## Features

- **AI Document Titles & Tags** — Automatically generate descriptive titles and assign tags using LLMs
- **AI-Powered OCR** — Supercharge OCR with LLM Vision models for high accuracy, even with tricky scans
- **Multiple LLM Providers** — OpenAI, Ollama, Mistral, Anthropic, Google AI, and any OpenAI-compatible endpoint (Scaleway, OpenRouter, vLLM, LiteLLM, etc.)
- **Multiple OCR Providers** — LLM Vision, Google Document AI, Azure Document Intelligence, Docling
- **Home Assistant Integration** — Configure everything via the HA UI, no manual env vars needed

## Installation

1. Click the badge above or add this repository to your Home Assistant:
   ```
   https://github.com/YOUR_GITHUB_USERNAME/paperless-gpt-haos
   ```
2. Install the "Paperless-GPT" add-on
3. Configure the add-on (see below)
4. Start the add-on
5. Access the web UI at `http://homeassistant.local:8080`

## Configuration

### Minimum Configuration (OpenAI)

| Option | Value |
|--------|-------|
| Paperless Base URL | `http://paperless-ngx:8000` |
| Paperless API Token | Your Paperless-NGX API token |
| LLM Provider | `openai` |
| LLM Model | `gpt-4o` |
| OpenAI API Key | Your OpenAI API key |

### Using a Custom OpenAI-Compatible Endpoint (Scaleway, OpenRouter, vLLM, etc.)

| Option | Value |
|--------|-------|
| LLM Provider | `openai` |
| LLM Model | e.g. `mistral-small-3.2-24b-instruct-2506` |
| OpenAI API Key | Your API key |
| OpenAI Base URL | e.g. `https://api.scaleway.ai/your-project-id/v1` |

### Using Ollama (Local)

| Option | Value |
|--------|-------|
| LLM Provider | `ollama` |
| LLM Model | e.g. `qwen3:8b` |
| Ollama Host | `http://host.docker.internal:11434` |

### OCR with LLM Vision

| Option | Value |
|--------|-------|
| OCR Provider | `llm` |
| Vision LLM Provider | `openai` (or `ollama`) |
| Vision LLM Model | `gpt-4o` (or `minicpm-v` for Ollama) |

### All Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `paperless_base_url` | string | `http://paperless-ngx:8000` | URL of your Paperless-NGX instance |
| `paperless_api_token` | string | — | Paperless-NGX API token (required) |
| `paperless_public_url` | string? | — | Public URL for Paperless (optional) |
| `llm_provider` | enum | `openai` | LLM provider: openai, ollama, mistral, anthropic, googleai |
| `llm_model` | string | `gpt-4o` | Model name |
| `openai_api_key` | string? | — | OpenAI API key |
| `openai_base_url` | string? | — | Custom OpenAI-compatible endpoint URL |
| `openai_api_type` | string? | — | Set to `azure` for Azure OpenAI |
| `mistral_api_key` | string? | — | Mistral API key |
| `anthropic_api_key` | string? | — | Anthropic API key |
| `googleai_api_key` | string? | — | Google AI (Gemini) API key |
| `ollama_host` | string? | — | Ollama server URL |
| `ollama_context_length` | int? | `8192` | Ollama context window |
| `token_limit` | int? | `0` | Token limit for smaller models |
| `llm_language` | string? | `English` | Expected document language |
| `manual_tag` | string? | `paperless-gpt` | Tag for manual processing |
| `auto_tag` | string? | `paperless-gpt-auto` | Tag for auto processing |
| `fail_tag` | string? | `paperless-gpt-failed` | Tag for failed processing |
| `ocr_provider` | enum | `llm` | OCR: llm, google_docai, azure, docling |
| `vision_llm_provider` | enum? | `openai` | Vision LLM: openai, ollama, mistral, anthropic |
| `vision_llm_model` | string? | `gpt-4o` | Vision model name |
| `ocr_process_mode` | enum | `image` | OCR mode: image, pdf, whole_pdf |
| `pdf_skip_existing_ocr` | bool? | `false` | Skip OCR for PDFs with existing text |
| `auto_ocr_tag` | string? | `paperless-gpt-ocr-auto` | Tag for auto OCR |
| `ocr_limit_pages` | int? | `5` | Max pages to OCR per document (0 = no limit) |
| `ocr_max_retries` | int? | `3` | Max OCR retries before fail-tagging |
| `create_local_hocr` | bool? | `false` | Save hOCR files locally |
| `create_local_pdf` | bool? | `false` | Save enhanced PDFs locally |
| `pdf_upload` | bool? | `false` | Upload enhanced PDFs to Paperless |
| `pdf_replace` | bool? | `false` | Replace original after upload (DANGEROUS) |
| `log_level` | enum | `info` | Log level: debug, info, warn, error |
| `listen_interface` | string? | `0.0.0.0:8080` | Listen address |

## Security

**paperless-gpt has no built-in authentication.** Its web UI is open to anyone who can reach the port. Do not expose it to the internet or an untrusted network. Use Home Assistant's network configuration to restrict access.

## Support

- [Paperless-GPT GitHub](https://github.com/icereed/paperless-gpt) — upstream project
- [Issues](https://github.com/YOUR_GITHUB_USERNAME/paperless-gpt-haos/issues) — add-on specific issues

## License

This add-on is licensed under the same license as [paperless-gpt](https://github.com/icereed/paperless-gpt).
