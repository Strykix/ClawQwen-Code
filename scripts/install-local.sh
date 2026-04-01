#!/usr/bin/env bash
set -euo pipefail

MODEL="${1:-qwen3-coder:30b}"
WORKDIR="${WORKDIR:-$HOME/dev}"
CLAW_SRC_DIR="${CLAW_SRC_DIR:-$WORKDIR/claw-code}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_FILE="$SCRIPT_DIR/../patches/claw-ollama-provider.patch"

log() {
  printf '[clawqwen] %s\n' "$*"
}

ensure_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    log "Missing command: $1"
    return 1
  }
}

if ! ensure_cmd git; then
  log "Please install git first."
  exit 1
fi

if ! ensure_cmd curl; then
  log "Please install curl first."
  exit 1
fi

if ! command -v cargo >/dev/null 2>&1; then
  log "Rust not found. Installing rustup..."
  curl -fsSL https://sh.rustup.rs | sh -s -- -y
  # shellcheck disable=SC1090
  source "$HOME/.cargo/env"
fi

if ! command -v ollama >/dev/null 2>&1; then
  log "Ollama not found. Installing..."
  curl -fsSL https://ollama.com/install.sh | sh
fi

if command -v systemctl >/dev/null 2>&1; then
  if ! systemctl is-active --quiet ollama; then
    log "Trying to start ollama service..."
    sudo systemctl enable --now ollama || true
  fi
fi

log "Preparing workspace at $WORKDIR"
mkdir -p "$WORKDIR"

if [ ! -d "$CLAW_SRC_DIR/.git" ]; then
  log "Cloning claw-code..."
  git clone https://github.com/instructkr/claw-code.git "$CLAW_SRC_DIR"
else
  log "Updating existing claw-code checkout..."
  git -C "$CLAW_SRC_DIR" fetch --all --prune
  git -C "$CLAW_SRC_DIR" pull --ff-only || true
fi

log "Applying provider patch..."
if git -C "$CLAW_SRC_DIR" apply --check "$PATCH_FILE" >/dev/null 2>&1; then
  git -C "$CLAW_SRC_DIR" apply "$PATCH_FILE"
  log "Patch applied."
elif git -C "$CLAW_SRC_DIR" apply --reverse --check "$PATCH_FILE" >/dev/null 2>&1; then
  log "Patch already applied."
else
  log "Patch cannot be applied automatically."
  log "Please inspect $PATCH_FILE and patch manually."
  exit 1
fi

log "Building claw-cli (release)..."
(
  cd "$CLAW_SRC_DIR/rust"
  cargo build --release -p claw-cli
)

log "Installing claw-bin and wrapper to $BIN_DIR"
mkdir -p "$BIN_DIR"
install -m 755 "$CLAW_SRC_DIR/rust/target/release/claw" "$BIN_DIR/claw-bin"

cat > "$BIN_DIR/claw" <<WRAP
#!/usr/bin/env bash
set -euo pipefail

: "\${OPENAI_BASE_URL:=http://127.0.0.1:11434/v1}"
: "\${OPENAI_API_KEY:=ollama}"
: "\${CLAW_MODEL:=${MODEL}}"
export OPENAI_BASE_URL OPENAI_API_KEY CLAW_MODEL

has_model_flag=0
for arg in "\$@"; do
  if [[ "\$arg" == "--model" || "\$arg" == --model=* ]]; then
    has_model_flag=1
    break
  fi
done

if [[ \$has_model_flag -eq 1 ]]; then
  exec "$BIN_DIR/claw-bin" "\$@"
else
  exec "$BIN_DIR/claw-bin" --model "\$CLAW_MODEL" "\$@"
fi
WRAP
chmod +x "$BIN_DIR/claw"

log "Pulling Ollama model: $MODEL"
ollama pull "$MODEL"

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  log "Add this to your shell profile if needed:"
  log "  export PATH=\"$BIN_DIR:\$PATH\""
fi

log "Done. Quick test:"
log "  claw --output-format json -p \"Reply with OK only\""
