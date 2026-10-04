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
   - `paperless_base_url` — URL of your Paperless-NGX instance (default `http://paperless-ngx:8000`)
   - `paperless_api_token` — API token from Paperless-NGX
   - `openai_api_key` — your API key for the configured endpoint
4. Save and start the add-on
5. Click **Open Web UI** or navigate to `http://homeassistant.local:8080`

### Defaults (v0.28.0+)

The add-on ships pre-configured for **Scaleway AI** (OpenAI-compatible) with the **`pixtral-12b-2409`** vision model:

- `llm_provider`: `openai`
- `llm_model`: `pixtral-12b-2409`
- `openai_base_url`: `https://api.scaleway.ai/<your-project-id>/v1`
- `vision_llm_provider`: `openai`
- `vision_llm_model`: `pixtral-12b-2409`
- `ocr_provider`: `llm`

To go live you only need to add:
- your **Paperless-NGX API token** (`paperless_api_token`)
- your **Scaleway API key** (`openai_api_key`)

If you use a different provider, simply change `openai_base_url` / `llm_model` / `vision_llm_model` to match your endpoint (any OpenAI-compatible API works: OpenRouter, vLLM, LiteLLM, LM Studio, etc.).

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

### Add to the Home Assistant sidebar

To get a clickable entry in the Home Assistant sidebar (like other add-ons/apps):

1. Make sure the add-on is **running** (the web UI is available on `http://homeassistant.local:8080`)
2. Open the add-on page in Home Assistant → **Info** tab
3. Toggle **"Show in sidebar"** ("In der Seitenleiste anzeigen") **ON**
4. The add-on now appears in the sidebar; clicking it opens the UI directly

> Note: This relies on the `webui` key being present in `config.yaml` (it is). The sidebar toggle itself is a per-installation Home Assistant setting controlled by the user — it cannot be forced from the repository. Adding a "Webpage" dashboard entry (Settings → Dashboards) is an alternative, but the built-in add-on toggle is the recommended way.

### Data Storage

Custom prompts are stored in the add-on config folder (`/config/prompts`, visible as `addon_configs/<id>_paperless_gpt/prompts` via Samba or Studio Code Server). Edit them there and restart the add-on. Settings (`/data/config`), the modification history (`/data/db`), hOCR files and enhanced PDFs are stored in the add-on's data volume (`/data`).

## Extra request fields (openai_extra_body)

Some OpenAI-compatible providers accept parameters that paperless-gpt cannot
send, for example Scaleway's `reasoning_effort` for reasoning models. Set
`openai_extra_body` to a JSON object and the add-on adds it to every chat
request for `llm_model`:

```yaml
llm_provider: openai
llm_model: gemma-4-26b-a4b-it
openai_base_url: https://api.scaleway.ai/<project-id>/v1
openai_extra_body: '{"reasoning_effort":"none"}'
```

Requests for other models (e.g. the vision/OCR model) pass through unchanged.
The add-on log shows `openai_extra_body active …` at start and
`llm-proxy: added … field(s)` for each modified request.
