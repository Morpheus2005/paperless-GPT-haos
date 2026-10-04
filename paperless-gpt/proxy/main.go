// llm-proxy: small reverse proxy in front of an OpenAI-compatible API.
//
// paperless-gpt (v0.28.x) cannot pass provider-specific request parameters
// such as "reasoning_effort". This proxy adds a fixed set of JSON fields to
// every POST .../chat/completions request whose "model" is listed in
// PROXY_MODELS, and forwards everything else unchanged.
//
// Environment:
//
// PROXY_UPSTREAM    upstream base URL, e.g. https://api.scaleway.ai/<project>/v1
// PROXY_EXTRA_BODY  JSON object merged into matching requests,
//                   e.g. {"reasoning_effort":"none"}
// PROXY_MODELS      comma-separated model names to modify (empty = all)
// PROXY_LISTEN      listen address (default 127.0.0.1:18080)
//
// Fields already present in a request are never overwritten.
package main

import (
	"bytes"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strings"
)

func main() {
	listen := envOr("PROXY_LISTEN", "127.0.0.1:18080")
	upstream, err := url.Parse(strings.TrimRight(os.Getenv("PROXY_UPSTREAM"), "/"))
	if err != nil || upstream.Scheme == "" || upstream.Host == "" {
		log.Fatalf("llm-proxy: invalid PROXY_UPSTREAM %q", os.Getenv("PROXY_UPSTREAM"))
	}
	var extra map[string]json.RawMessage
	if err := json.Unmarshal([]byte(os.Getenv("PROXY_EXTRA_BODY")), &extra); err != nil || len(extra) == 0 {
		log.Fatalf("llm-proxy: PROXY_EXTRA_BODY must be a non-empty JSON object")
	}
	models := map[string]bool{}
	for _, m := range strings.Split(os.Getenv("PROXY_MODELS"), ",") {
		if m = strings.TrimSpace(m); m != "" {
			models[m] = true
		}
	}
	proxy := &httputil.ReverseProxy{
		Rewrite: func(r *httputil.ProxyRequest) {
			// Joins the upstream path with the incoming path:
			// /<project>/v1 + /chat/completions
			r.SetURL(upstream)
		},
	}
	handler := http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		if req.Method == http.MethodPost && strings.HasSuffix(req.URL.Path, "/chat/completions") {
			if changed, err := inject(req, extra, models); err != nil {
				log.Printf("llm-proxy: request passed through unchanged: %v", err)
			} else if changed {
				log.Printf("llm-proxy: added %d field(s) to %s", len(extra), req.URL.Path)
			}
		}
		proxy.ServeHTTP(w, req)
	})
	keys := make([]string, 0, len(extra))
	for k := range extra {
		keys = append(keys, k)
	}
	log.Printf("llm-proxy: listening on %s, upstream %s, fields %v, models %v",
		listen, upstream.Redacted(), keys, keysOf(models))
	log.Fatal(http.ListenAndServe(listen, handler))
}

// inject merges extra into the JSON body if the model matches.
// On any error the original body is restored and forwarded unchanged.
func inject(req *http.Request, extra map[string]json.RawMessage, models map[string]bool) (bool, error) {
	body, err := io.ReadAll(req.Body)
	req.Body.Close()
	setBody(req, body)
	if err != nil {
		return false, err
	}
	var payload map[string]json.RawMessage
	if err := json.Unmarshal(body, &payload); err != nil {
		return false, err
	}
	if len(models) > 0 {
		var model string
		_ = json.Unmarshal(payload["model"], &model)
		if !models[model] {
			return false, nil
		}
	}
	changed := false
	for k, v := range extra {
		if _, exists := payload[k]; !exists {
			payload[k] = v
			changed = true
		}
	}
	if !changed {
		return false, nil
	}
	newBody, err := json.Marshal(payload)
	if err != nil {
		return false, err
	}
	setBody(req, newBody)
	return true, nil
}

func setBody(req *http.Request, b []byte) {
	req.Body = io.NopCloser(bytes.NewReader(b))
	req.ContentLength = int64(len(b))
	req.Header.Del("Content-Length")
}

func envOr(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func keysOf(m map[string]bool) []string {
	out := make([]string, 0, len(m))
	for k := range m {
		out = append(out, k)
	}
	return out
}
