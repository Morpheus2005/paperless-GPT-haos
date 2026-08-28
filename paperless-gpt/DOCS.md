# Paperless-GPT

## Setup

This add-on runs [paperless-gpt](https://github.com/icereed/paperless-gpt), which enhances [Paperless-NGX](https://github.com/paperless-ngx/paperless-ngx) with AI-powered document titles, tags, and OCR.

### Prerequisites

1. **Paperless-NGX** must be installed and running (as a Home Assistant add-on or externally)
2. You need an **API token** from Paperless-NGX (Settings → API Tokens → Create Token)
3. Access to an **LLM provider**:
   - **OpenAI**: API key with models like `gpt-4o`
   - **Ollama**: Running Ollama server with models like `qwen3:8b`
   - **Mistral**: API key with `mistral-large-latest`
   - **Anthropic**: API key with `claude-sonnet-4-5`
   - **Custom OpenAI-compatible**: Any provider that exposes an OpenAI-compatible API (Scaleway AI, OpenRouter, vLLM, LiteLLM, LM Studio, etc.)

### Quick Start

1. Install the add-on
2. Go to the **Configuration** tab
3. Set at minimum:
   - `paperless_base_url` — URL of your Paperless-NGX instance
   - `paperless_api_token` — API token from Paperless-NGX
   - `llm_provider` — your LLM provider
   - `llm_model` — model name
   - API key for your chosen provider
4. Save and start the add-on
5. Click **Open Web UI** or navigate to `http://homeassistant.local:8080`

### Using Custom OpenAI-Compatible Endpoints

You can use any OpenAI-compatible API by setting:

- `llm_provider`: `openai`
- `openai_base_url`: Your endpoint URL (e.g. `https://api.scaleway.ai/your-project/v1`)
- `openai_api_key`: Your API key
- `llm_model`: Model name available at your endpoint

For Vision/OCR with a custom endpoint:

- `ocr_provider`: `llm`
- `vision_llm_provider`: `openai`
- `vision_llm_model`: A vision-capable model (e.g. `pixtral-12b-2409`)

### Tags

paperless-gpt uses tags to manage processing:

- **paperless-gpt** — Documents tagged with this will be processed when you click "Process" in the UI
- **paperless-gpt-auto** — Documents tagged with this are processed automatically
- **paperless-gpt-failed** — Processing failed (will not be retried automatically)

You can customize these tag names in the add-on configuration.

### OCR Modes

- **image** (default): Renders each page as an image and sends to the Vision LLM
- **pdf**: Processes the PDF directly (if the LLM supports it)
- **whole_pdf**: Sends the entire PDF as one request

### Network

The add-on exposes port 8080 for the web UI. By default, Home Assistant maps this to the same port. You can change the host port in the add-on's Network configuration.

### Data Storage

Persistent data (hOCR files, enhanced PDFs, prompts) is stored in the add-on's data volume (`/data`).
