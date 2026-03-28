#!/usr/bin/env zsh
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo "${GREEN}[INFO]${NC} $*" }
warn()    { echo "${YELLOW}[WARN]${NC} $*" }
error()   { echo "${RED}[ERROR]${NC} $*"; exit 1 }

ensure_line() {
  local line="$1"
  local file="$2"
  touch "$file"
  grep -qxF "$line" "$file" || echo "$line" >> "$file"
}

# ── Homebrew ──────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  BREW_SHELLENV='eval "$(/opt/homebrew/bin/brew shellenv)"'
  ensure_line "$BREW_SHELLENV" "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  info "Homebrew already installed, updating..."
  brew update --quiet
fi

# ── CLI tools ─────────────────────────────────────────────────────────────────
info "Installing CLI tools..."
brew install --quiet \
  git \
  gh \
  node \
  eza bat zoxide btop fzf fd \
  ripgrep jq yq git-delta uv \
  zsh-autosuggestions zsh-syntax-highlighting \
  helix

# ── Rust ─────────────────────────────────────────────────────────────────────
if ! command -v rustc &>/dev/null; then
  info "Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --quiet
  source "$HOME/.cargo/env"
else
  info "Rust already installed: $(rustc --version)"
fi

# ── npm globals ───────────────────────────────────────────────────────────────
info "Installing npm global packages..."
npm install -g @github/copilot

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  info "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  info "Oh My Zsh already installed"
fi

# ── Powerlevel10k ─────────────────────────────────────────────────────────────
P10K_LINE='source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme'
ZSH_AUTOSUGGESTIONS_LINE='source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh'
ZSH_SYNTAX_HIGHLIGHTING_LINE='source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'

if ! brew list powerlevel10k &>/dev/null; then
  info "Installing Powerlevel10k..."
  brew install --quiet powerlevel10k
else
  info "Powerlevel10k already installed"
fi

ensure_line "$P10K_LINE" "$HOME/.zshrc"
ensure_line "$ZSH_AUTOSUGGESTIONS_LINE" "$HOME/.zshrc"
ensure_line "$ZSH_SYNTAX_HIGHLIGHTING_LINE" "$HOME/.zshrc"

# ── Workspace ─────────────────────────────────────────────────────────────────
[[ -d "$HOME/Repos" ]] || mkdir -p "$HOME/Repos"

# ── Done ──────────────────────────────────────────────────────────────────────
info "Setup complete! Open a new terminal or run: source ~/.zshrc"
info "Powerlevel10k was installed but not configured automatically."
info "If you want the interactive wizard later, run: p10k configure"
info "Run 'rustup update' occasionally to keep Rust current."
