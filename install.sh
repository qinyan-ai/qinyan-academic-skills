#!/bin/bash
# 沁言学术科研论文 Skills 库 - 安装与更新脚本
#
# 用法:
#   安装全部:        bash install.sh
#   安装某个分类:    bash install.sh --category 01
#   安装单个skill:   bash install.sh --skill academic-paper-search
#   安装到项目:      bash install.sh --project
#   列出所有分类:    bash install.sh --list
#   列出所有skills:  bash install.sh --list-skills
#   搜索skill:       bash install.sh --search 论文
#   指定工具:        bash install.sh --tool cursor
#   检查更新:        bash install.sh --check-update
#   更新全部:        bash install.sh --update
#   更新单个skill:   bash install.sh --update --skill scanpy
#   更新某个分类:    bash install.sh --update --category 05
#   查看已安装:      bash install.sh --status
#   强制更新:        bash install.sh --update --force
#   查看版本:        bash install.sh --version
#
# 远程一键安装:
#   curl -fsSL https://raw.githubusercontent.com/qinyan-ai/qinyan-academic-skills/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/qinyan-ai/qinyan-academic-skills/main/install.sh | bash -s -- --skill scanpy
#   curl -fsSL https://raw.githubusercontent.com/qinyan-ai/qinyan-academic-skills/main/install.sh | bash -s -- --category 05
#   curl -fsSL https://raw.githubusercontent.com/qinyan-ai/qinyan-academic-skills/main/install.sh | bash -s -- --check-update
#   curl -fsSL https://raw.githubusercontent.com/qinyan-ai/qinyan-academic-skills/main/install.sh | bash -s -- --update

set -e

SCRIPT_VERSION="1.2.0"
REPO_URL="https://github.com/qinyan-ai/qinyan-academic-skills.git"
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# ========== 参数解析 ==========
SCOPE="global"
MODE="all"
TARGET=""
TOOL="claude"
SEARCH_TERM=""
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --project)
            SCOPE="project"; shift ;;
        --category|-c)
            MODE="category"; TARGET="$2"; shift 2 ;;
        --skill|-s)
            if [ "$MODE" = "update" ]; then
                TARGET="$2"
            else
                MODE="skill"; TARGET="$2"
            fi
            shift 2 ;;
        --list|-l)
            MODE="list"; shift ;;
        --list-skills|-ls)
            MODE="list-skills"; shift ;;
        --search)
            MODE="search"; SEARCH_TERM="$2"; shift 2 ;;
        --tool|-t)
            TOOL="$2"; shift 2 ;;
        --check-update|--check)
            MODE="check-update"; shift ;;
        --update|-u)
            MODE="update"; shift ;;
        --status)
            MODE="status"; shift ;;
        --force|-f)
            FORCE=true; shift ;;
        --version|-v)
            MODE="version"; shift ;;
        --help|-h)
            MODE="help"; shift ;;
        *)
            # 兼容旧用法: 第一个参数作为分类
            if [ -z "$TARGET" ]; then
                MODE="category"; TARGET="$1"
            fi
            shift ;;
    esac
done

# ========== 版本信息 ==========
if [ "$MODE" = "version" ]; then
    echo "沁言学术 Skills 安装脚本 v${SCRIPT_VERSION}"
    exit 0
fi

# ========== 帮助信息 ==========
if [ "$MODE" = "help" ]; then
    cat << 'HELP'
沁言学术科研论文 Skills 库 - 安装与更新脚本

用法:
  bash install.sh [选项]

安装选项:
  (无参数)                    安装全部 Skills
  --category, -c <编号/名称>  安装某个分类 (如: 01, 05, "01-论文检索与文献管理")
  --skill, -s <名称>          安装单个 Skill (如: scanpy, academic-paper-search)
  --project                   安装到当前项目目录 (而非全局)
  --tool, -t <工具>           指定目标工具: claude(默认), cursor, codex, gemini, openclaw

浏览选项:
  --list, -l                  列出所有分类
  --list-skills, -ls          列出所有 Skills
  --search <关键词>           搜索 Skills (如: 论文, 蛋白质, ML)

更新选项:
  --check-update, --check     检查已安装 Skills 是否有更新
  --update, -u                更新已安装的 Skills (默认全部)
  --update -s <名称>          更新单个 Skill
  --update -c <编号>          更新某个分类
  --force, -f                 强制更新 (跳过本地修改检测)
  --status                    查看已安装 Skills 的状态

其他选项:
  --version, -v               显示脚本版本
  --help, -h                  显示帮助

远程一键安装示例:
  # 安装全部
  curl -fsSL https://raw.githubusercontent.com/qinyan-ai/qinyan-academic-skills/main/install.sh | bash

  # 安装单个 Skill
  curl -fsSL https://raw.githubusercontent.com/qinyan-ai/qinyan-academic-skills/main/install.sh | bash -s -- --skill scanpy

  # 检查更新
  curl -fsSL https://raw.githubusercontent.com/qinyan-ai/qinyan-academic-skills/main/install.sh | bash -s -- --check-update

  # 更新全部
  curl -fsSL https://raw.githubusercontent.com/qinyan-ai/qinyan-academic-skills/main/install.sh | bash -s -- --update

  # 更新单个 Skill
  curl -fsSL https://raw.githubusercontent.com/qinyan-ai/qinyan-academic-skills/main/install.sh | bash -s -- --update -s scanpy

  # 安装到 Cursor
  curl -fsSL https://raw.githubusercontent.com/qinyan-ai/qinyan-academic-skills/main/install.sh | bash -s -- --tool cursor

  # 安装到 OpenClaw
  curl -fsSL https://raw.githubusercontent.com/qinyan-ai/qinyan-academic-skills/main/install.sh | bash -s -- --tool openclaw
HELP
    exit 0
fi

# ========== 安装目录 ==========
case $TOOL in
    claude)   SKILLS_DIR=".claude/skills" ;;
    cursor)   SKILLS_DIR=".cursor/skills" ;;
    codex)    SKILLS_DIR=".codex/skills" ;;
    gemini)   SKILLS_DIR=".gemini/skills" ;;
    openclaw) SKILLS_DIR=".openclaw/skills" ;;
    *)        echo "错误: 不支持的工具 '$TOOL'，可选: claude, cursor, codex, gemini, openclaw"; exit 1 ;;
esac

if [ "$SCOPE" = "project" ]; then
    INSTALL_DIR="$PWD/$SKILLS_DIR"
else
    INSTALL_DIR="$HOME/$SKILLS_DIR"
fi

# 元数据目录 (存放 lock.json 等)
META_DIR="$(dirname "$INSTALL_DIR")/.qinyan-skills"

# ========== 工具函数 ==========

# 计算目录的内容指纹 (用于检测本地修改)
compute_fingerprint() {
    local dir="$1"
    if [ -d "$dir" ]; then
        find "$dir" -type f -not -path '*/.qinyan-skills/*' -exec md5sum {} \; 2>/dev/null | sort | md5sum | awk '{print $1}'
    else
        echo ""
    fi
}

# 读取 lock.json 中某个 skill 的信息
get_lock_info() {
    local skill_name="$1"
    local field="$2"
    local lock_file="$META_DIR/lock.json"
    if [ -f "$lock_file" ] && command -v python3 &>/dev/null; then
        python3 -c "
import json, sys
try:
    with open('$lock_file') as f:
        data = json.load(f)
    skill = data.get('skills', {}).get('$skill_name', {})
    print(skill.get('$field', ''))
except:
    pass
" 2>/dev/null
    fi
}

# 写入/更新 lock.json
update_lock() {
    local skill_name="$1"
    local commit_hash="$2"
    local category="$3"
    local fingerprint="$4"
    local lock_file="$META_DIR/lock.json"

    mkdir -p "$META_DIR"

    if ! command -v python3 &>/dev/null; then
        # 没有 python3 时写入简单格式
        echo "{\"version\":\"$SCRIPT_VERSION\",\"updated\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" > "$lock_file"
        return
    fi

    python3 -c "
import json, os
from datetime import datetime

lock_file = '$lock_file'
data = {'version': '$SCRIPT_VERSION', 'repo': '$REPO_URL', 'skills': {}}

if os.path.exists(lock_file):
    try:
        with open(lock_file) as f:
            data = json.load(f)
    except:
        pass

if 'skills' not in data:
    data['skills'] = {}

data['skills']['$skill_name'] = {
    'commit': '$commit_hash',
    'category': '$category',
    'fingerprint': '$fingerprint',
    'installed_at': data.get('skills', {}).get('$skill_name', {}).get('installed_at', datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')),
    'updated_at': datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
}

data['version'] = '$SCRIPT_VERSION'
data['repo'] = '$REPO_URL'

with open(lock_file, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
" 2>/dev/null
}

# 从 lock.json 中移除 skill
remove_from_lock() {
    local skill_name="$1"
    local lock_file="$META_DIR/lock.json"

    if [ -f "$lock_file" ] && command -v python3 &>/dev/null; then
        python3 -c "
import json
with open('$lock_file') as f:
    data = json.load(f)
data.get('skills', {}).pop('$skill_name', None)
with open('$lock_file', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
" 2>/dev/null
    fi
}

# 获取远程仓库最新 commit hash (无需完整 clone)
get_remote_commit() {
    git ls-remote --head "$REPO_URL" main 2>/dev/null | awk '{print $1}' | head -c 12
}

# ========== 克隆仓库 ==========
clone_repo() {
    if [ ! -d "$TEMP_DIR/repo" ]; then
        echo "📦 正在获取 Skills 库..."
        git clone --depth 1 -q "$REPO_URL" "$TEMP_DIR/repo" 2>/dev/null
    fi
}

get_repo_commit() {
    git -C "$TEMP_DIR/repo" rev-parse --short=12 HEAD 2>/dev/null
}

# ========== 查看已安装状态 ==========
if [ "$MODE" = "status" ]; then
    lock_file="$META_DIR/lock.json"
    if [ ! -f "$lock_file" ]; then
        echo "📭 未检测到安装记录"
        echo ""
        echo "如果您之前安装过 Skills 但没有安装记录，请重新安装以启用版本追踪："
        echo "  bash install.sh"
        exit 0
    fi

    echo ""
    echo "📊 已安装 Skills 状态"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📍 安装目录: $INSTALL_DIR"
    echo ""

    if command -v python3 &>/dev/null; then
        python3 -c "
import json
with open('$lock_file') as f:
    data = json.load(f)
skills = data.get('skills', {})
print(f'📦 脚本版本: {data.get(\"version\", \"未知\")}')
print(f'📚 已安装: {len(skills)} 个 Skills')
print()

# 按分类分组
categories = {}
for name, info in sorted(skills.items()):
    cat = info.get('category', '未分类')
    if cat not in categories:
        categories[cat] = []
    categories[cat].append((name, info))

for cat in sorted(categories.keys()):
    items = categories[cat]
    print(f'【{cat}】({len(items)} 个)')
    for name, info in items:
        commit = info.get('commit', '?')[:8]
        updated = info.get('updated_at', '?')[:10]
        print(f'  • {name:<32} commit:{commit}  更新:{updated}')
    print()
" 2>/dev/null
    else
        echo "需要 python3 来解析安装记录"
        cat "$lock_file"
    fi
    exit 0
fi

# ========== 检查更新 ==========
if [ "$MODE" = "check-update" ]; then
    lock_file="$META_DIR/lock.json"
    if [ ! -f "$lock_file" ]; then
        echo "📭 未检测到安装记录，无法检查更新"
        echo "提示: 请先安装 Skills，安装时会自动创建版本追踪记录"
        exit 0
    fi

    echo "🔍 正在检查更新..."
    echo ""

    # 获取远程最新信息
    clone_repo
    REMOTE_COMMIT=$(get_repo_commit)
    SKILLS_ROOT="$TEMP_DIR/repo/skills"

    if ! command -v python3 &>/dev/null; then
        echo "需要 python3 来检查更新"
        exit 1
    fi

    has_update=false
    has_modified=false
    up_to_date=0
    need_update=0
    locally_modified=0

    python3 -c "
import json
with open('$lock_file') as f:
    data = json.load(f)
skills = data.get('skills', {})
for name in sorted(skills.keys()):
    print(name)
" 2>/dev/null | while read -r skill_name; do
        local_commit=$(get_lock_info "$skill_name" "commit")
        local_fp=$(get_lock_info "$skill_name" "fingerprint")

        # 检查本地文件是否被修改
        current_fp=""
        if [ -d "$INSTALL_DIR/$skill_name" ]; then
            current_fp=$(compute_fingerprint "$INSTALL_DIR/$skill_name")
        fi

        # 计算远程文件指纹
        remote_fp=""
        for remote_skill_dir in "$SKILLS_ROOT"/*/"$skill_name"; do
            if [ -d "$remote_skill_dir" ]; then
                remote_fp=$(compute_fingerprint "$remote_skill_dir")
                break
            fi
        done

        if [ -z "$remote_fp" ]; then
            # 远程已不存在此 skill
            printf "  ⚠️  %-32s 远程已移除\n" "$skill_name"
        elif [ "$current_fp" != "$local_fp" ] && [ -n "$local_fp" ] && [ -n "$current_fp" ]; then
            printf "  ✏️  %-32s 本地已修改\n" "$skill_name"
        elif [ "$remote_fp" != "$current_fp" ]; then
            printf "  🔄 %-32s 有新版本可用\n" "$skill_name"
        else
            printf "  ✅ %-32s 已是最新\n" "$skill_name"
        fi
    done

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "远程最新 commit: $REMOTE_COMMIT"
    echo ""
    echo "更新命令:"
    echo "  更新全部:    bash install.sh --update"
    echo "  更新单个:    bash install.sh --update -s <skill名称>"
    echo "  强制更新:    bash install.sh --update --force"
    exit 0
fi

# ========== 更新逻辑 ==========
if [ "$MODE" = "update" ]; then
    lock_file="$META_DIR/lock.json"
    if [ ! -f "$lock_file" ]; then
        echo "📭 未检测到安装记录"
        echo ""
        echo "将执行全新安装..."
        MODE="all"
        # 继续执行下面的安装逻辑
    else
        clone_repo
        REMOTE_COMMIT=$(get_repo_commit)
        SKILLS_ROOT="$TEMP_DIR/repo/skills"

        echo "🔄 正在更新 Skills..."
        echo "   远程版本: $REMOTE_COMMIT"
        echo ""

        updated=0
        skipped=0
        failed=0

        # 确定要更新的 skill 列表
        if [ -n "$TARGET" ]; then
            # 更新指定 skill 或分类
            skill_list="$TARGET"
        else
            # 更新全部已安装的 skills
            if command -v python3 &>/dev/null; then
                skill_list=$(python3 -c "
import json
with open('$lock_file') as f:
    data = json.load(f)
for name in sorted(data.get('skills', {}).keys()):
    print(name)
" 2>/dev/null)
            else
                echo "需要 python3 来解析安装记录"
                exit 1
            fi
        fi

        for skill_name in $skill_list; do
            # 查找远程 skill 目录
            remote_skill_dir=""
            remote_category=""
            for d in "$SKILLS_ROOT"/*/; do
                if [ -d "$d/$skill_name" ]; then
                    remote_skill_dir="$d/$skill_name"
                    remote_category=$(basename "$d")
                    break
                fi
            done

            # 模糊匹配
            if [ -z "$remote_skill_dir" ]; then
                for d in "$SKILLS_ROOT"/*/*/; do
                    dname=$(basename "$d")
                    if [[ "$dname" == *"$skill_name"* ]]; then
                        remote_skill_dir="$d"
                        remote_category=$(basename "$(dirname "$d")")
                        skill_name=$(basename "$d")
                        break
                    fi
                done
            fi

            if [ -z "$remote_skill_dir" ]; then
                printf "  ⚠️  %-32s 远程未找到，跳过\n" "$skill_name"
                skipped=$((skipped + 1))
                continue
            fi

            # 检查是否需要更新
            remote_fp=$(compute_fingerprint "$remote_skill_dir")
            current_fp=""
            if [ -d "$INSTALL_DIR/$skill_name" ]; then
                current_fp=$(compute_fingerprint "$INSTALL_DIR/$skill_name")
            fi
            local_fp=$(get_lock_info "$skill_name" "fingerprint")

            # 检查本地是否有修改
            if [ "$current_fp" != "$local_fp" ] && [ -n "$local_fp" ] && [ -n "$current_fp" ] && [ "$FORCE" != true ]; then
                printf "  ✏️  %-32s 本地已修改，跳过 (使用 --force 强制更新)\n" "$skill_name"
                skipped=$((skipped + 1))
                continue
            fi

            if [ "$remote_fp" = "$current_fp" ] && [ "$FORCE" != true ]; then
                printf "  ✅ %-32s 已是最新\n" "$skill_name"
                continue
            fi

            # 执行更新
            rm -rf "${INSTALL_DIR:?}/$skill_name"
            cp -r "$remote_skill_dir" "$INSTALL_DIR/"
            update_lock "$skill_name" "$REMOTE_COMMIT" "$remote_category" "$remote_fp"
            printf "  🔄 %-32s 已更新\n" "$skill_name"
            updated=$((updated + 1))
        done

        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "更新完成: $updated 个更新, $skipped 个跳过"
        echo "📍 安装目录: $INSTALL_DIR"
        exit 0
    fi
fi

# ========== 克隆仓库 (安装模式) ==========
clone_repo
REMOTE_COMMIT=$(get_repo_commit)
SKILLS_ROOT="$TEMP_DIR/repo/skills"

# ========== 列出分类 ==========
if [ "$MODE" = "list" ]; then
    echo ""
    echo "📚 可用分类:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    for d in "$SKILLS_ROOT"/*/; do
        name=$(basename "$d")
        count=$(find "$d" -maxdepth 1 -mindepth 1 -type d | wc -l)
        printf "  %-36s (%d skills)\n" "$name" "$count"
    done
    echo ""
    echo "安装示例: bash install.sh --category 01"
    exit 0
fi

# ========== 列出所有 Skills ==========
if [ "$MODE" = "list-skills" ]; then
    echo ""
    echo "📚 全部 Skills:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    for d in "$SKILLS_ROOT"/*/; do
        category=$(basename "$d")
        echo ""
        echo "【$category】"
        for s in "$d"*/; do
            [ -d "$s" ] && printf "  • %s\n" "$(basename "$s")"
        done
    done
    echo ""
    exit 0
fi

# ========== 搜索 Skills ==========
if [ "$MODE" = "search" ]; then
    echo ""
    echo "🔍 搜索 '$SEARCH_TERM':"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    found=0
    for d in "$SKILLS_ROOT"/*/; do
        category=$(basename "$d")
        for s in "$d"*/; do
            [ ! -d "$s" ] && continue
            skill_name=$(basename "$s")
            # 搜索目录名和 SKILL.md 内容
            if echo "$skill_name $category" | grep -qi "$SEARCH_TERM" 2>/dev/null || \
               ([ -f "$s/SKILL.md" ] && grep -qi "$SEARCH_TERM" "$s/SKILL.md" 2>/dev/null); then
                # 提取 SKILL.md 的 description
                desc=""
                if [ -f "$s/SKILL.md" ]; then
                    desc=$(grep -m1 '^description:' "$s/SKILL.md" 2>/dev/null | sed 's/^description:[[:space:]]*//' | sed 's/^"//' | sed 's/"$//' | head -c 80)
                fi
                printf "  %-30s [%s]\n" "$skill_name" "$category"
                [ -n "$desc" ] && printf "    %s\n" "$desc"
                found=$((found + 1))
            fi
        done
    done
    echo ""
    echo "找到 $found 个匹配的 Skills"
    [ $found -gt 0 ] && echo "安装示例: bash install.sh --skill <名称>"
    exit 0
fi

# ========== 安装逻辑 ==========
mkdir -p "$INSTALL_DIR"

install_skill_dir() {
    local src="$1"
    local name=$(basename "$src")
    local category=$(basename "$(dirname "$src")")
    local fp=$(compute_fingerprint "$src")
    cp -r "$src" "$INSTALL_DIR/"
    update_lock "$name" "$REMOTE_COMMIT" "$category" "$fp"
    echo "  ✅ $name"
}

case $MODE in
    all)
        echo "🚀 安装全部 Skills 到 $INSTALL_DIR"
        echo ""
        total=0
        for category_dir in "$SKILLS_ROOT"/*/; do
            category=$(basename "$category_dir")
            echo "📂 $category"
            for skill_dir in "$category_dir"*/; do
                [ -d "$skill_dir" ] && install_skill_dir "$skill_dir" && total=$((total + 1))
            done
        done
        echo ""
        echo "🎉 安装完成！共 $total 个 Skills"
        ;;
    category)
        # 支持编号匹配 (如 "01" 匹配 "01-论文检索与文献管理")
        matched_dir=""
        for d in "$SKILLS_ROOT"/*/; do
            dirname=$(basename "$d")
            if [ "$dirname" = "$TARGET" ] || [[ "$dirname" == ${TARGET}-* ]] || [[ "$dirname" == *"$TARGET"* ]]; then
                matched_dir="$d"
                break
            fi
        done

        if [ -z "$matched_dir" ]; then
            echo "❌ 未找到分类 '$TARGET'"
            echo ""
            echo "可用分类:"
            for d in "$SKILLS_ROOT"/*/; do
                echo "  $(basename "$d")"
            done
            exit 1
        fi

        category_name=$(basename "$matched_dir")
        echo "🚀 安装分类 [$category_name] 到 $INSTALL_DIR"
        echo ""
        count=0
        for skill_dir in "$matched_dir"*/; do
            [ -d "$skill_dir" ] && install_skill_dir "$skill_dir" && count=$((count + 1))
        done
        echo ""
        echo "🎉 安装完成！共 $count 个 Skills"
        ;;
    skill)
        # 在所有分类中搜索指定 skill
        found_dir=""
        found_category=""
        for d in "$SKILLS_ROOT"/*/; do
            if [ -d "$d/$TARGET" ]; then
                found_dir="$d/$TARGET"
                found_category=$(basename "$d")
                break
            fi
        done

        # 模糊匹配
        if [ -z "$found_dir" ]; then
            for d in "$SKILLS_ROOT"/*/*/; do
                dirname=$(basename "$d")
                if [[ "$dirname" == *"$TARGET"* ]]; then
                    found_dir="$d"
                    found_category=$(basename "$(dirname "$d")")
                    break
                fi
            done
        fi

        if [ -z "$found_dir" ]; then
            echo "❌ 未找到 Skill '$TARGET'"
            echo ""
            echo "使用 --search 搜索: bash install.sh --search $TARGET"
            exit 1
        fi

        echo "🚀 安装 Skill [$(basename "$found_dir")] (来自 $found_category)"
        echo "   目标: $INSTALL_DIR"
        echo ""
        install_skill_dir "$found_dir"
        echo ""
        echo "🎉 安装完成！"
        ;;
esac

echo "📍 安装目录: $INSTALL_DIR"
