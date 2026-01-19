#!/bin/bash

# OPC Skills Installer
# Install agent skills to Claude Code, Factory Droid, OpenCode, or custom directories

set -e

REPO_URL="https://github.com/ReScienceLab/opc-skills"
REPO_RAW="https://raw.githubusercontent.com/ReScienceLab/opc-skills/main"
SKILLS_DIR="skills"
TEMP_DIR=""
CLEANUP_TEMP="false"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Progress tracking
TOTAL_SKILLS=0
CURRENT_SKILL=0

print_header() {
    echo -e "${BLUE}"
    cat << 'EOF'
                    __        
 ___  ___  ____ ___/ /__ _  __
/ _ \/ _ \/ __// _  / -_) |/ /
\___/ .__/\__(_)_,_/\__/|___/ 
   /_/                        
EOF
    echo -e "${NC}"
    echo -e "${BLUE}       Skills Installer${NC}"
    print_separator
}

print_separator() {
    echo -e "${DIM}──────────────────────────────────────${NC}"
}

print_dependency_tree() {
    local skill=$1
    local deps=$(get_skill_deps "$skill")
    
    echo ""
    echo -e "  ${CYAN}Installing:${NC}"
    
    if [ -n "$deps" ]; then
        echo -e "  └─ ${skill}"
        local dep_array=($deps)
        local last_idx=$((${#dep_array[@]} - 1))
        local i=0
        for dep in $deps; do
            if [ $i -eq $last_idx ]; then
                echo -e "     └─ ${DIM}${dep}${NC}"
            else
                echo -e "     ├─ ${DIM}${dep}${NC}"
            fi
            ((i++))
        done
    else
        echo -e "  └─ ${skill}"
    fi
    echo ""
}

print_install_progress() {
    local skill=$1
    local status=$2
    
    ((CURRENT_SKILL++))
    if [ "$status" = "start" ]; then
        printf "  [%d/%d] %-18s " "$CURRENT_SKILL" "$TOTAL_SKILLS" "$skill"
    elif [ "$status" = "done" ]; then
        echo -e "${GREEN}✓${NC}"
    elif [ "$status" = "fail" ]; then
        echo -e "${RED}✗${NC}"
    fi
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}→ $1${NC}"
}

cleanup() {
    if [ "$CLEANUP_TEMP" = "true" ] && [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

# Track installed skills to avoid duplicates
INSTALLED_SKILLS=""

# Path to skills.json (set after determining source)
SKILLS_JSON_PATH=""
SKILLS_JSON_CONTENT=""

# Strip carriage returns for Windows compatibility (Git Bash outputs CRLF)
strip_cr() {
    tr -d '\r'
}

# Check if jq is available
check_jq() {
    if command -v jq &> /dev/null; then
        return 0
    fi
    
    print_warning "jq not found, attempting to install..."
    
    if command -v brew &> /dev/null; then
        brew install jq 2>/dev/null && return 0
    elif command -v apt-get &> /dev/null; then
        sudo apt-get install -y jq 2>/dev/null && return 0
    elif command -v yum &> /dev/null; then
        sudo yum install -y jq 2>/dev/null && return 0
    elif command -v apk &> /dev/null; then
        sudo apk add jq 2>/dev/null && return 0
    fi
    
    print_error "Please install jq: https://stedolan.github.io/jq/download/"
    exit 1
}

# Load skills.json content
load_skills_json() {
    if [ -n "$SKILLS_JSON_CONTENT" ]; then
        return 0
    fi

    if [ "$USE_LOCAL" = "true" ] && [ -f "$SCRIPT_DIR/skills.json" ]; then
        SKILLS_JSON_PATH="$SCRIPT_DIR/skills.json"
        SKILLS_JSON_CONTENT=$(cat "$SKILLS_JSON_PATH")
    else
        # Download skills.json from GitHub
        SKILLS_JSON_CONTENT=$(curl -fsSL "$REPO_RAW/skills.json" 2>/dev/null) || {
            print_error "Could not load skills.json"
            exit 1
        }
    fi
}

# Get all available skill names from skills.json
get_available_skills() {
    load_skills_json || return 1
    echo "$SKILLS_JSON_CONTENT" | jq -r '.skills[].name' | strip_cr | tr '\n' ' '
}

# Validate if a skill exists in skills.json
validate_skill() {
    local skill=$1
    load_skills_json || return 1
    echo "$SKILLS_JSON_CONTENT" | jq -e --arg s "$skill" \
        '.skills[] | select(.name == $s)' > /dev/null 2>&1
}

# Get dependencies for a skill from skills.json
get_skill_deps() {
    local skill=$1
    load_skills_json || return 1
    echo "$SKILLS_JSON_CONTENT" | jq -r --arg s "$skill" \
        '.skills[] | select(.name == $s) | .dependencies // [] | .[]' 2>/dev/null | strip_cr | tr '\n' ' '
}

# Get skill description from skills.json
get_skill_description() {
    local skill=$1
    load_skills_json || return 1
    echo "$SKILLS_JSON_CONTENT" | jq -r --arg s "$skill" \
        '.skills[] | select(.name == $s) | .description // ""' 2>/dev/null | strip_cr
}

# Check if skill requires authentication
skill_requires_auth() {
    local skill=$1
    load_skills_json || return 1
    
    local required=$(echo "$SKILLS_JSON_CONTENT" | jq -r --arg s "$skill" \
        '.skills[] | select(.name == $s) | .auth.required // false' 2>/dev/null | strip_cr)
    
    if [ "$required" = "true" ]; then
        return 0  # true - requires auth
    else
        return 1  # false - no auth
    fi
}

# Get environment variable name for skill auth
get_skill_env_var() {
    local skill=$1
    load_skills_json || return 1
    echo "$SKILLS_JSON_CONTENT" | jq -r --arg s "$skill" \
        '.skills[] | select(.name == $s) | .auth.env_var // empty' 2>/dev/null | strip_cr
}

# Get auth note/instructions for skill
get_skill_auth_note() {
    local skill=$1
    load_skills_json || return 1
    echo "$SKILLS_JSON_CONTENT" | jq -r --arg s "$skill" \
        '.skills[] | select(.name == $s) | .auth.note // empty' 2>/dev/null | strip_cr
}

# Get example URL for skill from links.example
get_skill_example_url() {
    local skill=$1
    load_skills_json || return 1
    echo "$SKILLS_JSON_CONTENT" | jq -r --arg s "$skill" \
        '.skills[] | select(.name == $s) | .links.example // empty' 2>/dev/null | strip_cr
}

# Detect user's shell profile
get_shell_profile() {
    local shell_name=$(basename "$SHELL")
    case $shell_name in
        zsh) echo "$HOME/.zshrc" ;;
        bash)
            if [ -f "$HOME/.bash_profile" ]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        fish) echo "$HOME/.config/fish/config.fish" ;;
        *) echo "$HOME/.profile" ;;
    esac
}

# Check if an environment variable is set (handles comma-separated list)
is_env_var_set() {
    local var_names=$1
    # Handle comma-separated list - check first variable only
    local first_var=$(echo "$var_names" | cut -d',' -f1 | xargs)
    eval "[ -n \"\${$first_var:-}\" ]"
}

# Print post-install instructions with auth awareness
print_post_install_instructions() {
    local skill=$1
    local installed_skills=$2

    echo ""
    print_separator
    print_success "Installation complete!"
    print_separator
    echo ""

    # Count installed skills
    local skill_count=$(echo "$installed_skills" | wc -w | xargs)
    local dep_count=$((skill_count - 1))
    
    if [ "$skill" = "all" ]; then
        echo -e "  Installed ${GREEN}$skill_count${NC} skills"
    elif [ "$dep_count" -gt 0 ]; then
        echo -e "  Installed ${GREEN}$skill${NC} + $dep_count dependencies"
    else
        echo -e "  Installed ${GREEN}$skill${NC}"
    fi
    echo ""

    # Show API key status for each skill
    echo -e "  ${CYAN}API Keys:${NC}"
    local skills_missing_keys=""
    
    for s in $installed_skills; do
        local env_var=$(get_skill_env_var "$s")
        if skill_requires_auth "$s"; then
            if is_env_var_set "$env_var"; then
                printf "    ${GREEN}✓${NC} %-16s ${DIM}configured${NC}\n" "$s"
            else
                printf "    ${YELLOW}⚠${NC} %-16s ${YELLOW}missing${NC} (${DIM}$env_var${NC})\n" "$s"
                skills_missing_keys="$skills_missing_keys $s"
            fi
        else
            printf "    ${GREEN}✓${NC} %-16s ${DIM}not required${NC}\n" "$s"
        fi
    done
    echo ""

    # Trim whitespace
    skills_missing_keys=$(echo "$skills_missing_keys" | xargs)

    # Show missing key instructions if needed
    if [ -n "$skills_missing_keys" ]; then
        echo -e "  ${YELLOW}Configure missing keys:${NC}"
        local shell_profile=$(get_shell_profile)
        local shown_vars=""
        for s in $skills_missing_keys; do
            local env_vars=$(get_skill_env_var "$s")
            local auth_note=$(get_skill_auth_note "$s")
            # Handle comma-separated env vars
            local first_var=$(echo "$env_vars" | cut -d',' -f1 | xargs)
            # Skip if already shown
            if echo "$shown_vars" | grep -q "$first_var"; then
                continue
            fi
            shown_vars="$shown_vars $first_var"
            echo -e "    export $first_var=\"...\""
            if [ -n "$auth_note" ]; then
                echo -e "    ${DIM}# $auth_note${NC}"
            fi
        done
        echo ""
    fi

    # Next steps
    echo -e "  ${CYAN}Next steps:${NC}"
    local example_skill="$skill"
    if [ "$skill" = "all" ]; then
        example_skill=$(echo "$installed_skills" | awk '{print $1}')
    fi

    if [ -n "$skills_missing_keys" ]; then
        echo "    1. Configure the missing API key(s)"
        echo "    2. Restart your AI coding assistant"
        echo "    3. Try: \"Use the $example_skill skill to...\""
    else
        echo "    1. Restart your AI coding assistant"
        echo "    2. Try: \"Use the $example_skill skill to...\""
    fi

    # Show example URL if available
    local example_url=$(get_skill_example_url "$skill")
    if [ -n "$example_url" ]; then
        echo ""
        echo -e "  ${CYAN}Docs:${NC} ${DIM}$example_url${NC}"
    fi
    echo ""
}

show_help() {
    echo "Usage: ./install.sh [OPTIONS] <skill>"
    echo ""
    echo "Skills:"
    # Dynamically list skills from skills.json
    load_skills_json 2>/dev/null
    if [ -n "$SKILLS_JSON_CONTENT" ]; then
        echo "$SKILLS_JSON_CONTENT" | jq -r '.skills[] | "  \(.name | . + " " * (15 - length)) \(.description | .[0:50])..."' 2>/dev/null | strip_cr || {
            echo "  (run with -h after jq is installed to see skill list)"
        }
    else
        echo "  (skills list loaded from skills.json)"
    fi
    echo "  all              Install all skills"
    echo ""
    echo "Options:"
    echo "  -t, --tool TOOL    Target tool: claude, droid, opencode, cursor, custom"
    echo "  -d, --dir DIR      Custom skills directory (use with -t custom)"
    echo "  -p, --project      Install to current project (default: user-level/global)"
    echo "  --no-deps          Don't install dependencies"
    echo "  -h, --help         Show this help"
    echo ""
    echo "Installation Levels:"
    echo "  User-level (default): Skills available to you across ALL projects"
    echo "  Project-level (-p):   Skills shared with anyone working in THIS repo"
    echo ""
    echo "Examples:"
    echo "  # User-level install (available everywhere)"
    echo "  curl -fsSL .../install.sh | bash -s -- -t claude reddit"
    echo "  curl -fsSL .../install.sh | bash -s -- -t droid all"
    echo ""
    echo "  # Project-level install (shared with team)"
    echo "  curl -fsSL .../install.sh | bash -s -- -t claude -p reddit"
    echo "  curl -fsSL .../install.sh | bash -s -- -t droid -p all"
    echo ""
    echo "Directories:"
    echo "  Tool        User-level (~)              Project-level (.)"
    echo "  ─────────   ─────────────────────────   ─────────────────────"
    echo "  claude      ~/.claude/skills            .claude/skills"
    echo "  droid       ~/.factory/skills           .factory/skills"
    echo "  cursor      -                           .cursor/skills"
    echo "  opencode    ~/.config/opencode/skills   .opencode/skills"
    echo "  codex       ~/.codex/skills             .codex/skills"
    echo ""
    echo "Notes:"
    echo "  - Codex requires: codex --enable skills"
    echo "  - OpenCode uses singular 'skill' dir internally, symlink may be needed"
}

get_skills_dir() {
    local tool=$1
    local project=$2

    case $tool in
        claude)
            if [ "$project" = "true" ]; then
                echo ".claude/skills"
            else
                echo "$HOME/.claude/skills"
            fi
            ;;
        droid)
            if [ "$project" = "true" ]; then
                echo ".factory/skills"
            else
                echo "$HOME/.factory/skills"
            fi
            ;;
        cursor)
            echo ".cursor/skills"
            ;;
        opencode)
            if [ "$project" = "true" ]; then
                echo ".opencode/skills"
            else
                echo "$HOME/.config/opencode/skills"
            fi
            ;;
        codex)
            if [ "$project" = "true" ]; then
                echo ".codex/skills"
            else
                echo "$HOME/.codex/skills"
            fi
            ;;
        *)
            echo ""
            ;;
    esac
}

download_skill() {
    local skill=$1
    local target_dir=$2
    
    # Show progress
    ((CURRENT_SKILL++))
    printf "  [%d/%d] %-18s " "$CURRENT_SKILL" "$TOTAL_SKILLS" "$skill"
    
    mkdir -p "$target_dir/$skill"
    
    # Download SKILL.md
    curl -fsSL "$REPO_RAW/skills/$skill/SKILL.md" -o "$target_dir/$skill/SKILL.md" 2>/dev/null || {
        echo -e "${RED}✗${NC}"
        print_error "Failed to download $skill/SKILL.md"
        return 1
    }
    
    # Get list of files in skill directory from GitHub API
    local files_json=$(curl -fsSL "https://api.github.com/repos/ReScienceLab/opc-skills/contents/skills/$skill" 2>/dev/null)
    
    # Download scripts directory if exists
    if echo "$files_json" | grep -q '"name": *"scripts"'; then
        mkdir -p "$target_dir/$skill/scripts"
        local scripts_json=$(curl -fsSL "https://api.github.com/repos/ReScienceLab/opc-skills/contents/skills/$skill/scripts" 2>/dev/null)
        
        # Parse and download each script file
        echo "$scripts_json" | grep -o '"download_url": *"[^"]*"' | cut -d'"' -f4 | while read -r url; do
            if [ -n "$url" ] && [ "$url" != "null" ]; then
                local filename=$(basename "$url")
                curl -fsSL "$url" -o "$target_dir/$skill/scripts/$filename" 2>/dev/null
            fi
        done
    fi
    
    # Download references directory if exists
    if echo "$files_json" | grep -q '"name": *"references"'; then
        mkdir -p "$target_dir/$skill/references"
        local refs_json=$(curl -fsSL "https://api.github.com/repos/ReScienceLab/opc-skills/contents/skills/$skill/references" 2>/dev/null)
        
        echo "$refs_json" | grep -o '"download_url": *"[^"]*"' | cut -d'"' -f4 | while read -r url; do
            if [ -n "$url" ] && [ "$url" != "null" ]; then
                local filename=$(basename "$url")
                curl -fsSL "$url" -o "$target_dir/$skill/references/$filename" 2>/dev/null
            fi
        done
    fi
    
    echo -e "${GREEN}✓${NC}"
}

# Install a skill with its dependencies
install_with_deps() {
    local skill=$1
    local target_dir=$2
    local source_dir=$3
    local use_local=$4
    
    # Skip if already installed
    if echo "$INSTALLED_SKILLS" | grep -q " $skill "; then
        return 0
    fi
    
    # Get dependencies
    local deps=$(get_skill_deps "$skill")
    
    # Install dependencies first
    if [ -n "$deps" ] && [ "$INSTALL_DEPS" = "true" ]; then
        for dep in $deps; do
            if ! echo "$INSTALLED_SKILLS" | grep -q " $dep "; then
                install_with_deps "$dep" "$target_dir" "$source_dir" "$use_local"
            fi
        done
    fi
    
    # Install the skill itself
    if [ "$use_local" = "true" ]; then
        install_skill_from_local "$skill" "$target_dir" "$source_dir"
    else
        download_skill "$skill" "$target_dir"
    fi
    
    INSTALLED_SKILLS="$INSTALLED_SKILLS $skill "
}

install_skill_from_local() {
    local skill=$1
    local target_dir=$2
    local source_dir=$3

    if [ ! -d "$source_dir/$skill" ]; then
        echo -e "${RED}✗${NC}"
        print_error "Skill '$skill' not found in $source_dir"
        return 1
    fi

    # Show progress
    ((CURRENT_SKILL++))
    printf "  [%d/%d] %-18s " "$CURRENT_SKILL" "$TOTAL_SKILLS" "$skill"

    mkdir -p "$target_dir"
    
    if [ -d "$target_dir/$skill" ]; then
        rm -rf "$target_dir/$skill"
    fi

    cp -r "$source_dir/$skill" "$target_dir/"
    echo -e "${GREEN}✓${NC}"
}

# Parse arguments
TOOL=""
CUSTOM_DIR=""
PROJECT="false"
SKILL=""
INSTALL_DEPS="true"

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--tool)
            TOOL="$2"
            shift 2
            ;;
        -d|--dir)
            CUSTOM_DIR="$2"
            shift 2
            ;;
        -p|--project)
            PROJECT="true"
            shift
            ;;
        --no-deps)
            INSTALL_DEPS="false"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            SKILL="$1"
            shift
            ;;
    esac
done

# Validate inputs
if [ -z "$SKILL" ]; then
    print_header
    echo "Select a skill to install:"
    echo ""
    
    # Build dynamic menu from skills.json
    load_skills_json
    SKILL_NAMES=$(echo "$SKILLS_JSON_CONTENT" | jq -r '.skills[].name' | strip_cr)
    SKILL_COUNT=$(echo "$SKILL_NAMES" | wc -l | xargs)
    
    local i=1
    while IFS= read -r skill_name; do
        local desc=$(echo "$SKILLS_JSON_CONTENT" | jq -r --arg s "$skill_name" \
            '.skills[] | select(.name == $s) | .description | .[0:40]' 2>/dev/null | strip_cr)
        printf "  %d) %-15s - %s...\n" "$i" "$skill_name" "$desc"
        ((i++))
    done <<< "$SKILL_NAMES"
    
    echo "  $i) all            - All skills"
    echo ""
    
    local all_choice=$i
    read -p "Enter choice [1-$all_choice]: " choice
    
    if [ "$choice" = "$all_choice" ]; then
        SKILL="all"
    elif [ "$choice" -ge 1 ] && [ "$choice" -lt "$all_choice" ] 2>/dev/null; then
        SKILL=$(echo "$SKILL_NAMES" | sed -n "${choice}p")
    else
        print_error "Invalid choice"
        exit 1
    fi
fi

if [ -z "$TOOL" ]; then
    echo ""
    echo "Select target tool:"
    echo ""
    echo "  1) claude    - Claude Code"
    echo "  2) droid     - Factory Droid"
    echo "  3) cursor    - Cursor"
    echo "  4) opencode  - OpenCode"
    echo "  5) codex     - OpenAI Codex"
    echo "  6) custom    - Custom directory"
    echo ""
    read -p "Enter choice [1-6]: " choice
    case $choice in
        1) TOOL="claude" ;;
        2) TOOL="droid" ;;
        3) TOOL="cursor" ;;
        4) TOOL="opencode" ;;
        5) TOOL="codex" ;;
        6) TOOL="custom" ;;
        *) print_error "Invalid choice"; exit 1 ;;
    esac
fi

# Get target directory
if [ "$TOOL" = "custom" ]; then
    if [ -z "$CUSTOM_DIR" ]; then
        read -p "Enter custom skills directory: " CUSTOM_DIR
    fi
    TARGET_DIR="$CUSTOM_DIR"
else
    TARGET_DIR=$(get_skills_dir "$TOOL" "$PROJECT")
fi

if [ -z "$TARGET_DIR" ]; then
    print_error "Unknown tool: $TOOL"
    exit 1
fi

# Determine source: local repo or download from GitHub
SCRIPT_DIR=""
SOURCE_DIR=""
USE_LOCAL="false"

# Try to detect if running from local repo (not piped via curl)
if [ -n "${BASH_SOURCE[0]:-}" ] && [ "${BASH_SOURCE[0]}" != "bash" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || true
    if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/$SKILLS_DIR" ]; then
        SOURCE_DIR="$SCRIPT_DIR/$SKILLS_DIR"
        USE_LOCAL="true"
    fi
fi

# Check jq is available (required for parsing skills.json)
check_jq

# Load skills.json early
load_skills_json

# Validate skill name if not "all"
if [ "$SKILL" != "all" ]; then
    if ! validate_skill "$SKILL"; then
        print_error "Unknown skill: $SKILL"
        echo ""
        echo "Available skills:"
        get_available_skills | tr ' ' '\n' | sed 's/^/  /'
        exit 1
    fi
fi

print_header

# Show install info
echo ""
echo -e "  ${CYAN}Target:${NC} $TARGET_DIR"
if [ "$USE_LOCAL" = "true" ]; then
    echo -e "  ${CYAN}Source:${NC} Local"
else
    echo -e "  ${CYAN}Source:${NC} GitHub"
fi

mkdir -p "$TARGET_DIR"

# Install skill(s) with dependencies
if [ "$SKILL" = "all" ]; then
    ALL_SKILLS=$(get_available_skills)
    # Count total skills
    TOTAL_SKILLS=$(echo "$ALL_SKILLS" | wc -w | xargs)
    
    echo ""
    echo -e "  ${CYAN}Installing:${NC} all ($TOTAL_SKILLS skills)"
    echo ""
    print_separator
    echo ""
    
    for s in $ALL_SKILLS; do
        install_with_deps "$s" "$TARGET_DIR" "$SOURCE_DIR" "$USE_LOCAL"
    done
else
    # Get dependencies and calculate total
    deps=$(get_skill_deps "$SKILL")
    if [ -n "$deps" ] && [ "$INSTALL_DEPS" = "true" ]; then
        dep_count=$(echo "$deps" | wc -w | xargs)
        TOTAL_SKILLS=$((dep_count + 1))
    else
        TOTAL_SKILLS=1
    fi
    
    # Show dependency tree
    print_dependency_tree "$SKILL"
    print_separator
    echo ""
    
    install_with_deps "$SKILL" "$TARGET_DIR" "$SOURCE_DIR" "$USE_LOCAL"
fi

# Print auth-aware post-install instructions
print_post_install_instructions "$SKILL" "$INSTALLED_SKILLS"
