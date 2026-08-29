## 0.28.0

- **Fix**: Enable s6 init (`init: true`) — resolves `can't open /init: permission denied` on startup
- **Default provider**: Pre-configured for Scaleway AI (OpenAI-compatible) with the `pixtral-12b-2409` vision model
- **Vision/OCR**: `ocr_provider: llm`, `vision_llm_model: pixtral-12b-2409` (supports images/OCR) set as defaults
- Just add your Paperless-NGX API token and your Scaleway API key — no other setup needed
- Multi-arch builds: amd64, aarch64

## 0.27.0

- Initial release
- Based on paperless-gpt v0.27.0
- Supports all LLM providers: OpenAI, Ollama, Mistral, Anthropic, Google AI
- Supports custom OpenAI-compatible endpoints via OPENAI_BASE_URL
- Supports all OCR providers: LLM Vision, Google Document AI, Azure Document Intelligence, Docling
- Full Home Assistant UI configuration — no env vars needed
- Multi-arch builds: amd64, aarch64, armv7
