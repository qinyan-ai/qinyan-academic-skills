#!/usr/bin/env bash
# Academic Paper Search Skill - One-command installer
# Usage: curl -fsSL https://raw.githubusercontent.com/LeonChaoX/academic-paper-search-skill/main/install.sh | bash
# Or: bash install.sh [--project]
#
# Options:
#   --project    Install to current project's .claude/skills/ instead of global ~/.claude/skills/

set -euo pipefail

SKILL_NAME="academic-paper-search"
REPO_URL="https://github.com/LeonChaoX/academic-paper-search-skill.git"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# Determine install location
if [ "${1:-}" = "--project" ]; then
    INSTALL_DIR=".claude/skills/${SKILL_NAME}"
    info "Installing to project directory: ${INSTALL_DIR}"
else
    INSTALL_DIR="${HOME}/.claude/skills/${SKILL_NAME}"
    info "Installing to global directory: ${INSTALL_DIR}"
fi

# Check prerequisites
command -v git >/dev/null 2>&1 || error "git is required but not installed."
command -v curl >/dev/null 2>&1 || error "curl is required but not installed."
command -v python3 >/dev/null 2>&1 || error "python3 is required but not installed."

# Clean up existing installation
if [ -d "$INSTALL_DIR" ]; then
    warn "Existing installation found at ${INSTALL_DIR}"
    warn "Updating..."
    rm -rf "$INSTALL_DIR"
fi

# Create parent directory
mkdir -p "$(dirname "$INSTALL_DIR")"

# Clone repository
info "Cloning skill from ${REPO_URL}..."
git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" 2>/dev/null

# Make scripts executable
chmod +x "$INSTALL_DIR"/scripts/*.sh

# Remove git artifacts from install
rm -rf "$INSTALL_DIR/.git"

# Verify installation
if [ -f "$INSTALL_DIR/SKILL.md" ]; then
    ok "Skill installed successfully at: ${INSTALL_DIR}"
else
    error "Installation failed - SKILL.md not found"
fi

echo ""
echo "=============================================="
echo "  Academic Paper Search Skill Installed!"
echo "=============================================="
echo ""
echo "Next steps:"
echo ""
echo "  1. Set your API token:"
echo "     export ACADEMIC_API_TOKEN='your-bearer-token'"
echo ""
echo "  2. Add to your shell profile for persistence:"
echo "     echo 'export ACADEMIC_API_TOKEN=\"your-token\"' >> ~/.bashrc"
echo ""
echo "  3. Verify connectivity:"
echo "     curl -s http://47.95.10.101:9000/health"
echo ""
echo "  4. Start using in Claude Code / OpenClaw:"
echo "     - \"Search papers about deep learning\""
echo "     - \"Find SCI Q1 papers on medical imaging\""
echo "     - \"Analyze this paper: Attention Is All You Need\""
echo ""
echo "=============================================="
