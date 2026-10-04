## 0.28.4

- New option `openai_extra_body`: JSON object that is added to every chat request for `llm_model` when `llm_provider` is `openai`, e.g. `{"reasoning_effort":"none"}`. paperless-gpt itself cannot pass provider-specific parameters; a small built-in proxy (`llm-proxy`, see `proxy/`) adds them and forwards all other requests unchanged. Fields already present in a request are never overwritten.
- Motivation: reasoning models such as `gemma-4-26b-a4b-it` on Scaleway can loop in their reasoning phase and return no answer. With reasoning disabled they answer reliably and much faster.

## 0.28.3

- **Fix (persistence)**: paperless-gpt reads and writes `prompts/`, `config/` and `db/` relative to `/app`. These directories were not persistent, so custom prompts, settings (e.g. custom field selection) and the modification history were lost whenever the container was re-created. `run.sh` now links them to persistent storage:
  - `/app/prompts` → `/config/prompts` (editable via Samba / Studio Code under `addon_configs/`)
  - `/app/config` → `/data/config`
  - `/app/db` → `/data/db`
- **Fix**: Removed the default-prompt copy to `/data/prompts`. It checked for a non-existent `title.txt` and therefore ran on every start; the files were never read by paperless-gpt anyway. Missing prompts are still filled from the defaults by paperless-gpt itself, existing ones are never overwritten.
- **Migration**: On first start, prompts found in `/data/prompts` are copied to `/config/prompts` (only if that folder is still empty).
- **Build**: Upstream image pinned to `icereed/paperless-gpt:v0.28.0` (build arg `UPSTREAM_VERSION`) instead of `latest`, so every build ships the version the prompts were verified against.
- **Defaults**: Neutral defaults again (`llm_model` and `vision_llm_model`: `gpt-4o`, `openai_base_url` empty), matching the README. Existing installations keep their configured values; for Scaleway see the README example.

## 0.28.2

- **Fix (startup)**: Disable the custom AppArmor profile (`apparmor: false`) and remove the broken `apparmor.txt`. The hand-crafted s6-overlay v3 profile still denied PID 1 from opening `/init` (`Permission denied`, exit code 2) even with `init: false`. Running the container under Docker's default security profile boots s6-overlay cleanly (verified: with `--security-opt apparmor=<addon>` it fails, without it it starts).

## 0.28.1

- **Fix (startup)**: Root cause of `exec /init failed: Permission denied` was a missing/incorrect AppArmor profile. Added the s6-overlay v3 AppArmor rules required by the HA base image (`/init ix`, `/package/**`, `/run/s6/**`, etc.) so PID 1 can exec `/init` inside the container.
- **Fix**: Corrected `init` back to `false` (correct for s6 v3 base images) and set execute (`100755`) bits on `run.sh` and `rootfs/etc/cont-init.d/00-paperless-gpt.sh` — s6 v3 no longer auto-adds execute permission.

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
