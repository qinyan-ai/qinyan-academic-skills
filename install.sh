#!/bin/bash
# 沁言学术科研论文 Skills 库 - 一键安装脚本

set -e

REPO_URL="https://github.com/LeonChaoX/qinyan-academic-skills.git"
TEMP_DIR=$(mktemp -d)

# 检测安装目标
if [ "$1" = "--project" ]; then
    INSTALL_DIR=".claude/skills"
    echo "安装到当前项目: $INSTALL_DIR"
else
    INSTALL_DIR="$HOME/.claude/skills"
    echo "全局安装到: $INSTALL_DIR"
fi

# 支持 --category 参数选择分类安装
if [ -n "$2" ]; then
    CATEGORY="$2"
    echo "仅安装分类: $CATEGORY"
fi

echo "正在克隆仓库..."
git clone --depth 1 "$REPO_URL" "$TEMP_DIR/repo" 2>/dev/null

mkdir -p "$INSTALL_DIR"

if [ -n "$CATEGORY" ]; then
    # 安装指定分类
    if [ -d "$TEMP_DIR/repo/skills/$CATEGORY" ]; then
        cp -r "$TEMP_DIR/repo/skills/$CATEGORY"/* "$INSTALL_DIR/"
        echo "已安装分类 $CATEGORY 下的所有 Skills"
    else
        echo "错误: 未找到分类 '$CATEGORY'"
        echo "可用分类:"
        ls "$TEMP_DIR/repo/skills/"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
else
    # 安装全部
    for category_dir in "$TEMP_DIR/repo/skills"/*/; do
        cp -r "$category_dir"*/ "$INSTALL_DIR/" 2>/dev/null || true
    done
    echo "已安装全部 Skills"
fi

# 统计
skill_count=$(find "$INSTALL_DIR" -name "SKILL.md" -maxdepth 2 | wc -l)
echo "安装完成！共 $skill_count 个 Skills 已安装到 $INSTALL_DIR"

# 清理
rm -rf "$TEMP_DIR"
