# ClawQwen-Code

Setup local simple pour utiliser `claw-code` avec Ollama + Qwen coder, sans dependre d'une API cloud pour la generation.

## Objectif

- experience locale complete
- installation reproductible
- un seul binaire `claw` connecte a Ollama

## Quickstart

```bash
git clone https://github.com/Strykix/ClawQwen-Code.git
cd ClawQwen-Code
bash scripts/install-local.sh qwen3-coder:30b
```

Ensuite:

```bash
claw --output-format json -p "Reply with OK only"
```

## Ce que contient ce repo

- `scripts/install-local.sh`: installe et configure le setup local
- `patches/claw-ollama-provider.patch`: patch `claw-code` pour activer la selection provider compatible Ollama

## Ce que fait le script

1. clone ou met a jour `https://github.com/instructkr/claw-code`
2. applique le patch provider
3. compile `claw` en release
4. installe `claw-bin` et un wrapper `claw` dans `~/.local/bin`
5. pull le modele Ollama choisi

Par defaut, le wrapper utilise:

- `OPENAI_BASE_URL=http://127.0.0.1:11434/v1`
- `OPENAI_API_KEY=ollama`
- `CLAW_MODEL=qwen3-coder:30b`

## Modeles

- qualite code max locale: `qwen3-coder:30b`
- plus rapide sur machine limitee: `qwen2.5-coder:14b`

Exemple:

```bash
bash scripts/install-local.sh qwen2.5-coder:14b
```

## Prerequis

- Linux/WSL recommande
- `git`, `curl`, `cargo`, `ollama`

Si Rust manque:

```bash
curl -fsSL https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
```

Si Ollama manque:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

## Verification rapide

```bash
ollama ps
claw --output-format json -p "Reply with OK only"
```

## Note DNS OAuth

L'erreur `platform.claw.dev` (NXDOMAIN) n'est pas bloquante pour ce setup local Ollama.

## Disclaimer

Projet communautaire, non affilie a Anthropic, Ollama, ni aux auteurs originaux de `claw-code`.
