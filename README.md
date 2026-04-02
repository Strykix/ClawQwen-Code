# ClawQwen-Code

Run `claw-code` locally with Ollama + Qwen coder models.

This repo is designed to make local setup simple and reproducible.

## Quick Start

```bash
git clone https://github.com/Strykix/ClawQwen-Code.git
cd ClawQwen-Code
bash scripts/install-local.sh qwen3-coder:30b
```

Then test:

```bash
claw --output-format json -p "Reply with OK only"
```

## What This Repo Includes

- `scripts/install-local.sh`: one-command local installer
- `patches/claw-ollama-provider.patch`: patch for `claw-code` provider auto-selection (Ollama-compatible)

## What the Installer Does

1. Clones or updates `https://github.com/instructkr/claw-code`
2. Applies the provider patch
3. Builds `claw` in release mode
4. Installs `claw-bin` and a `claw` wrapper in `~/.local/bin`
5. Pulls the selected Ollama model

Default wrapper behavior:

- `OPENAI_BASE_URL=http://127.0.0.1:11434/v1`
- `OPENAI_API_KEY=ollama`
- `CLAW_MODEL=qwen3-coder:30b`

## Model Options

- Best local code quality: `qwen3-coder:30b`
- Faster on limited hardware: `qwen2.5-coder:14b`

Example:

```bash
bash scripts/install-local.sh qwen2.5-coder:14b
```

## Prerequisites

Recommended: Linux / WSL

Required tools:

- `git`
- `curl`
- `cargo` (Rust)
- `ollama`

If Rust is missing:

```bash
curl -fsSL https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
```

If Ollama is missing:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

## Quick Verification

```bash
ollama ps
claw --output-format json -p "Reply with OK only"
```

## Troubleshooting

### `platform.claw.dev` DNS / NXDOMAIN

This is not required for local Ollama mode. You can ignore OAuth endpoints when running fully local.

### `claw` command not found

Add local bin path:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Model is too slow

Use a smaller coder model, for example `qwen2.5-coder:14b`.

## Disclaimer

Community integration project. Not affiliated with Anthropic, Ollama, or the original `claw-code` authors.
