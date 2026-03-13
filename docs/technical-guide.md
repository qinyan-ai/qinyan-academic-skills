# 沁言学术 Skills 技术文档 — 搜索、检测更新与更新机制详解

## 目录

- [整体架构](#整体架构)
- [文件路径体系](#文件路径体系)
- [核心机制一：搜索 (--search)](#核心机制一搜索---search)
- [核心机制二：检测更新 (--check-update)](#核心机制二检测更新---check-update)
- [核心机制三：更新 (--update)](#核心机制三更新---update)
- [版本追踪系统 (lock.json)](#版本追踪系统-lockjson)
- [指纹算法](#指纹算法)
- [完整数据流图](#完整数据流图)
- [命令速查表](#命令速查表)

---

## 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                     用户执行 install.sh                       │
│  curl -fsSL .../install.sh | bash -s -- <参数>               │
└────────────────────────┬────────────────────────────────────┘
                         │
                    参数解析 (while case)
                         │
         ┌───────────────┼───────────────────┐
         │               │                   │
    安装类操作       浏览类操作          更新类操作
    (all/skill/     (list/search/       (check-update/
     category)       list-skills)        update/status)
         │               │                   │
         └───────┬───────┘                   │
                 │                           │
          git clone --depth 1          git clone --depth 1
          (远程仓库 → 临时目录)          + 读取 lock.json
                 │                           │
          遍历 skills/ 目录              指纹对比算法
                 │                           │
          复制到安装目录                  决定是否更新
          + 写入 lock.json               + 执行更新
```

### 脚本生命周期

1. **参数解析** → 确定 `MODE`（操作模式）、`TOOL`（目标工具）、`SCOPE`（全局/项目）
2. **路径计算** → 根据 TOOL 和 SCOPE 确定安装目录和元数据目录
3. **仓库克隆** → `git clone --depth 1` 到临时目录（所有需要远程数据的操作共享）
4. **执行操作** → 根据 MODE 分支执行
5. **清理退出** → `trap "rm -rf $TEMP_DIR" EXIT` 自动清理临时目录

---

## 文件路径体系

### 安装目录（按工具和作用域）

| 工具 | 全局安装路径 | 项目级安装路径 |
|------|-------------|---------------|
| Claude Code | `~/.claude/skills/<skill名>/` | `./.claude/skills/<skill名>/` |
| Cursor | `~/.cursor/skills/<skill名>/` | `./.cursor/skills/<skill名>/` |
| Codex | `~/.codex/skills/<skill名>/` | `./.codex/skills/<skill名>/` |
| Gemini CLI | `~/.gemini/skills/<skill名>/` | `./.gemini/skills/<skill名>/` |
| OpenClaw | `~/.openclaw/skills/<skill名>/` | `./.openclaw/skills/<skill名>/` |

### 元数据目录

```
~/.claude/.qinyan-skills/          ← 全局安装的元数据目录 (META_DIR)
    └── lock.json                  ← 版本追踪锁文件

./.claude/.qinyan-skills/          ← 项目级安装的元数据目录
    └── lock.json
```

**路径计算逻辑：**

```bash
# 安装目录
INSTALL_DIR="$HOME/.claude/skills"      # 全局 (默认)
INSTALL_DIR="$PWD/.claude/skills"       # 项目级 (--project)

# 元数据目录 = 安装目录的父目录 + .qinyan-skills
META_DIR="$(dirname "$INSTALL_DIR")/.qinyan-skills"
# 即: ~/.claude/.qinyan-skills/  或  ./.claude/.qinyan-skills/
```

### 远程仓库结构（临时目录中）

```
/tmp/tmp.XXXXXX/repo/               ← git clone 的临时目录
    └── skills/                     ← SKILLS_ROOT
        ├── 00-沁言学术OpenAPI/
        │   ├── qinyan-citation-search/
        │   │   ├── SKILL.md
        │   │   └── scripts/
        │   └── ...
        ├── 01-论文检索与文献管理/
        │   ├── academic-paper-search/
        │   │   ├── SKILL.md
        │   │   └── scripts/
        │   ├── scanpy/
        │   └── ...
        ├── 05-生物信息与基因组学/
        └── ...（共 17 个分类目录）
```

---

## 核心机制一：搜索 (--search)

### 触发命令

```bash
bash install.sh --search 蛋白质
# 或远程执行
curl -fsSL .../install.sh | bash -s -- --search 蛋白质
```

### 执行流程

```
用户输入: --search "蛋白质"
         │
         ▼
┌─────────────────────────┐
│ 1. git clone --depth 1  │  克隆仓库到临时目录
│    到 /tmp/xxx/repo/    │
└────────────┬────────────┘
             ▼
┌─────────────────────────┐
│ 2. 遍历 SKILLS_ROOT     │  双层循环: 分类目录 → skill 目录
│    /*/  →  /*/*/        │
└────────────┬────────────┘
             ▼
┌─────────────────────────────────────────┐
│ 3. 对每个 skill 做三重匹配:              │
│                                         │
│    a) 目录名匹配:                        │
│       echo "$skill_name $category"      │
│       | grep -qi "$SEARCH_TERM"         │
│                                         │
│    b) SKILL.md 内容全文匹配:             │
│       grep -qi "$SEARCH_TERM"           │
│       "$s/SKILL.md"                     │
│                                         │
│    任一匹配即命中                         │
└────────────┬────────────────────────────┘
             ▼
┌─────────────────────────────────────────┐
│ 4. 提取 description (从 SKILL.md):       │
│    grep -m1 '^description:' SKILL.md    │
│    | sed 去除前缀和引号                   │
│    | head -c 80 截断                     │
└────────────┬────────────────────────────┘
             ▼
┌─────────────────────────┐
│ 5. 格式化输出:            │
│  skill名称    [分类名]   │
│    description 描述      │
│                         │
│  找到 N 个匹配的 Skills  │
└─────────────────────────┘
```

### 搜索匹配范围

| 匹配源 | 示例 | 说明 |
|--------|------|------|
| skill 目录名 | `academic-paper-search` | 精确和部分匹配 |
| 分类目录名 | `05-生物信息与基因组学` | 匹配分类中文名 |
| SKILL.md 全文 | 文件中任何位置的文字 | 描述、标签、内容等 |

### 搜索示例输出

```
🔍 搜索 '蛋白质':
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  esm                            [08-蛋白质工程与结构生物学]
    蛋白质语言模型
  alphafold-database             [08-蛋白质工程与结构生物学]
    AlphaFold蛋白质结构数据库
  pdb-database                   [08-蛋白质工程与结构生物学]
    蛋白质结构数据库
  string-database                [12-科学数据库]
    蛋白质互作网络

找到 4 个匹配的 Skills
安装示例: bash install.sh --skill <名称>
```

---

## 核心机制二：检测更新 (--check-update)

### 触发命令

```bash
bash install.sh --check-update
# 或
bash install.sh --check
# 远程执行
curl -fsSL .../install.sh | bash -s -- --check-update
```

### 前置条件

必须存在 `lock.json` 文件（即之前通过 v1.1.0+ 的脚本安装过 Skills）。

### 执行流程

```
用户输入: --check-update
         │
         ▼
┌────────────────────────────────────┐
│ 1. 检查 lock.json 是否存在          │
│    路径: ~/.claude/.qinyan-skills/ │
│          lock.json                 │
│    不存在 → 提示先安装，退出         │
└────────────┬───────────────────────┘
             ▼
┌────────────────────────────────────┐
│ 2. git clone --depth 1 远程仓库     │
│    获取最新 commit hash             │
│    REMOTE_COMMIT = git rev-parse   │
│    --short=12 HEAD                 │
└────────────┬───────────────────────┘
             ▼
┌────────────────────────────────────┐
│ 3. python3 解析 lock.json          │
│    提取已安装的 skill 名称列表       │
└────────────┬───────────────────────┘
             ▼
┌────────────────────────────────────────────────────────┐
│ 4. 对每个已安装 skill 做三方指纹对比:                     │
│                                                        │
│    A = lock.json 中记录的指纹    (安装时的快照)           │
│    B = 本地安装目录的实际指纹    (当前磁盘状态)           │
│    C = 远程仓库中的指纹         (最新版本)               │
│                                                        │
│    ┌──────────────────────────────────────────────┐    │
│    │ 判断逻辑:                                     │    │
│    │                                              │    │
│    │ C 不存在        → ⚠️  远程已移除               │    │
│    │ A ≠ B (且都非空) → ✏️  本地已修改               │    │
│    │ B ≠ C           → 🔄 有新版本可用              │    │
│    │ B = C           → ✅ 已是最新                  │    │
│    └──────────────────────────────────────────────┘    │
└────────────┬───────────────────────────────────────────┘
             ▼
┌────────────────────────────────────┐
│ 5. 输出汇总报告 + 更新命令提示       │
└────────────────────────────────────┘
```

### 三方指纹对比原理图

```
安装时刻 t0                    当前时刻 t1
┌──────────────┐              ┌──────────────┐
│  远程仓库     │   install    │  本地安装目录  │
│  commit abc  │ ──────────►  │  ~/.claude/   │
│  指纹: FP_A  │              │  skills/xxx/  │
└──────────────┘              │  指纹: FP_B   │
       │                      └──────────────┘
       │ 记录到 lock.json            │
       ▼                             │
┌──────────────┐                     │
│  lock.json   │                     │
│  fingerprint │    FP_A ≠ FP_B ?    │
│  = FP_A      │ ◄───────────────────┘
└──────────────┘   是 → 本地被手动修改过

检查更新时刻 t2
┌──────────────┐
│  远程仓库     │   FP_C ≠ FP_B ?
│  (最新)      │   是 → 有新版本
│  指纹: FP_C  │
└──────────────┘
```

### 检测输出示例

```
🔍 正在检查更新...

  ✅ academic-paper-search          已是最新
  🔄 scanpy                         有新版本可用
  ✏️  pytorch-lightning              本地已修改
  ⚠️  old-deprecated-skill          远程已移除

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
远程最新 commit: 138b8a6abcde

更新命令:
  更新全部:    bash install.sh --update
  更新单个:    bash install.sh --update -s <skill名称>
  强制更新:    bash install.sh --update --force
```

---

## 核心机制三：更新 (--update)

### 触发命令

```bash
# 更新全部已安装的 skills
bash install.sh --update

# 更新单个 skill
bash install.sh --update -s scanpy

# 强制更新（忽略本地修改）
bash install.sh --update --force

# 远程执行
curl -fsSL .../install.sh | bash -s -- --update
curl -fsSL .../install.sh | bash -s -- --update -s scanpy --force
```

### 执行流程

```
用户输入: --update [-s <name>] [--force]
         │
         ▼
┌──────────────────────────────────────┐
│ 1. 检查 lock.json                     │
│    不存在 → 降级为全新安装 (MODE=all)   │
│    存在   → 继续更新流程               │
└────────────┬─────────────────────────┘
             ▼
┌──────────────────────────────────────┐
│ 2. git clone --depth 1 远程仓库       │
│    REMOTE_COMMIT = 最新 commit hash  │
└────────────┬─────────────────────────┘
             ▼
┌──────────────────────────────────────┐
│ 3. 确定更新范围:                       │
│    --update           → 全部已安装的   │
│    --update -s scanpy → 仅 scanpy    │
│    --update -c 05     → 仅第05分类    │
└────────────┬─────────────────────────┘
             ▼
┌────────────────────────────────────────────────────────┐
│ 4. 对每个 skill 执行更新决策:                            │
│                                                        │
│    a) 在远程仓库中查找 skill 目录                        │
│       先精确匹配: $SKILLS_ROOT/*/$skill_name            │
│       后模糊匹配: $SKILLS_ROOT/*/*/ 中 *skill_name*     │
│       找不到 → 跳过                                     │
│                                                        │
│    b) 计算三方指纹:                                      │
│       remote_fp = compute_fingerprint(远程目录)          │
│       current_fp = compute_fingerprint(本地安装目录)      │
│       local_fp = lock.json 中记录的指纹                  │
│                                                        │
│    c) 本地修改检测:                                      │
│       current_fp ≠ local_fp → 本地已修改                 │
│       无 --force → 跳过，提示用户                        │
│       有 --force → 强制覆盖                              │
│                                                        │
│    d) 远程变更检测:                                      │
│       remote_fp = current_fp → 已是最新，跳过            │
│       remote_fp ≠ current_fp → 需要更新                  │
└────────────┬───────────────────────────────────────────┘
             ▼
┌────────────────────────────────────────────────────────┐
│ 5. 执行更新:                                            │
│    rm -rf $INSTALL_DIR/$skill_name    ← 删除旧版本      │
│    cp -r $remote_skill_dir $INSTALL_DIR/  ← 复制新版本  │
│    update_lock(...)                   ← 更新 lock.json  │
└────────────┬───────────────────────────────────────────┘
             ▼
┌──────────────────────────────────────┐
│ 6. 输出汇总:                          │
│    更新完成: N 个更新, M 个跳过        │
└──────────────────────────────────────┘
```

### 更新决策矩阵

| 条件 | --force=false (默认) | --force=true |
|------|---------------------|-------------|
| 远程找不到 skill | 跳过 | 跳过 |
| 本地有修改 + 远程有更新 | 跳过，提示 --force | 强制覆盖更新 |
| 本地有修改 + 远程无更新 | 跳过，提示 --force | 强制覆盖 |
| 本地无修改 + 远程有更新 | 执行更新 | 执行更新 |
| 本地无修改 + 远程无更新 | 跳过（已是最新） | 强制重新安装 |

---

## 版本追踪系统 (lock.json)

### 文件路径

```
~/.claude/.qinyan-skills/lock.json     ← Claude Code 全局
~/.cursor/.qinyan-skills/lock.json     ← Cursor 全局
~/.openclaw/.qinyan-skills/lock.json   ← OpenClaw 全局
./.claude/.qinyan-skills/lock.json     ← 项目级
```

### 文件结构

```json
{
  "version": "1.1.0",
  "repo": "https://github.com/qinyan-ai/qinyan-academic-skills.git",
  "skills": {
    "scanpy": {
      "commit": "138b8a6abcde",
      "category": "05-生物信息与基因组学",
      "fingerprint": "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4",
      "installed_at": "2026-03-13T08:30:00Z",
      "updated_at": "2026-03-13T08:30:00Z"
    },
    "academic-paper-search": {
      "commit": "138b8a6abcde",
      "category": "01-论文检索与文献管理",
      "fingerprint": "b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5",
      "installed_at": "2026-03-10T12:00:00Z",
      "updated_at": "2026-03-13T08:30:00Z"
    }
  }
}
```

### 字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| `version` | string | install.sh 脚本版本 |
| `repo` | string | 来源仓库 URL |
| `skills.<name>.commit` | string | 安装/更新时的 git commit hash (前12位) |
| `skills.<name>.category` | string | skill 所属分类目录名 |
| `skills.<name>.fingerprint` | string | 安装时所有文件的 MD5 聚合指纹 |
| `skills.<name>.installed_at` | string | 首次安装时间 (UTC ISO 8601) |
| `skills.<name>.updated_at` | string | 最近更新时间 (UTC ISO 8601) |

### lock.json 的读写时机

| 操作 | 读 | 写 |
|------|---|---|
| `--status` | 读取全部，展示状态 | - |
| `--check-update` | 读取 fingerprint 做对比 | - |
| `--update` | 读取 skill 列表和 fingerprint | 更新变更的 skill 条目 |
| 安装 (all/skill/category) | - | 写入每个安装的 skill 条目 |

---

## 指纹算法

### 函数定义

```bash
compute_fingerprint() {
    local dir="$1"
    find "$dir" -type f \
        -not -path '*/.qinyan-skills/*' \
        -exec md5sum {} \; \
    | sort \
    | md5sum \
    | awk '{print $1}'
}
```

### 算法步骤

```
输入: skill 目录路径 (如 ~/.claude/skills/scanpy/)
         │
         ▼
┌────────────────────────────────────────────┐
│ 1. find 递归列出目录内所有普通文件            │
│    排除 .qinyan-skills/ 下的元数据文件       │
│    例如:                                    │
│      ./SKILL.md                            │
│      ./scripts/run.sh                      │
│      ./examples/demo.py                    │
└────────────┬───────────────────────────────┘
             ▼
┌────────────────────────────────────────────┐
│ 2. 对每个文件计算 MD5                        │
│    md5sum ./SKILL.md                       │
│    → "a1b2c3d4...  ./SKILL.md"             │
│    md5sum ./scripts/run.sh                 │
│    → "e5f6a7b8...  ./scripts/run.sh"       │
└────────────┬───────────────────────────────┘
             ▼
┌────────────────────────────────────────────┐
│ 3. sort 排序（确保文件顺序一致）              │
│    "a1b2c3d4...  ./SKILL.md"               │
│    "e5f6a7b8...  ./scripts/run.sh"         │
└────────────┬───────────────────────────────┘
             ▼
┌────────────────────────────────────────────┐
│ 4. 将排序后的全部 MD5 再做一次 MD5           │
│    → 最终指纹: "f9e8d7c6b5a4f3e2d1c0..."   │
└────────────────────────────────────────────┘

输出: 32位 MD5 hex 字符串 (目录内容的唯一标识)
```

### 为什么这样设计

- **排序保证确定性**：不同系统 `find` 返回顺序可能不同，排序消除差异
- **排除元数据**：`.qinyan-skills/` 目录存放的是追踪信息，不属于 skill 本身内容
- **二级 MD5**：先对每个文件算 MD5，再对所有 MD5 聚合算一次，兼顾效率和准确性
- **文件内容+路径**：MD5 输出包含文件路径，所以重命名文件也会改变指纹

---

## 完整数据流图

### 安装流程 (首次)

```
┌──────────┐     git clone      ┌───────────────┐
│  GitHub  │  ──────────────►  │  /tmp/xxx/repo │
│  远程仓库 │    --depth 1      │  (临时目录)     │
└──────────┘                    └───────┬───────┘
                                        │
                                   遍历 skills/
                                        │
                          ┌─────────────┼─────────────┐
                          │             │             │
                     cp -r skill1  cp -r skill2  cp -r skillN
                          │             │             │
                          ▼             ▼             ▼
                    ┌─────────────────────────────────────┐
                    │      ~/.claude/skills/               │
                    │      ├── scanpy/                    │
                    │      ├── academic-paper-search/     │
                    │      └── ...                        │
                    └─────────────────────────────────────┘
                                        │
                              compute_fingerprint()
                              对每个 skill 目录
                                        │
                                        ▼
                    ┌─────────────────────────────────────┐
                    │  ~/.claude/.qinyan-skills/lock.json  │
                    │  {                                   │
                    │    "skills": {                       │
                    │      "scanpy": {                     │
                    │        "commit": "138b8a...",        │
                    │        "fingerprint": "a1b2c3...",   │
                    │        "installed_at": "2026-..."    │
                    │      }                               │
                    │    }                                  │
                    │  }                                    │
                    └─────────────────────────────────────┘
```

### 检测更新流程

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│  ┌────────────┐    ┌────────────────┐    ┌──────────────────┐   │
│  │ lock.json  │    │ 本地安装目录     │    │ 远程仓库(最新)    │   │
│  │ 记录指纹 A  │    │ 实际指纹 B      │    │ 最新指纹 C       │   │
│  └─────┬──────┘    └───────┬────────┘    └────────┬─────────┘   │
│        │                   │                      │              │
│        └──────────┬────────┘                      │              │
│                   │                               │              │
│              A ≠ B ?                              │              │
│             ╱      ╲                              │              │
│           是        否                            │              │
│           │          │                            │              │
│     ✏️ 本地已修改     │                            │              │
│                      └───────────┬────────────────┘              │
│                                  │                               │
│                             B ≠ C ?                              │
│                            ╱      ╲                              │
│                          是        否                            │
│                          │          │                            │
│                    🔄 有新版本    ✅ 已是最新                      │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### 更新执行流程

```
     需要更新的 skill
           │
           ▼
  ┌─────────────────┐
  │ 本地有修改?       │
  │ (A ≠ B)         │
  └────┬────────┬───┘
     是│        │否
       ▼        ▼
  ┌────────┐  ┌──────────────┐
  │--force?│  │ remote ≠     │
  └──┬──┬──┘  │ current ?    │
   是│  │否   └──┬────────┬──┘
     │  │      是│        │否
     │  ▼        ▼        ▼
     │ 跳过   ┌───────┐  跳过
     │        │ 执行   │ (已最新)
     └──────► │ 更新   │
              └───┬───┘
                  │
     ┌────────────┼────────────┐
     │            │            │
     ▼            ▼            ▼
  rm -rf       cp -r       update_lock()
  旧目录      新文件        写入新指纹
```

---

## 命令速查表

### 安装命令

```bash
# 安装全部 (远程一键)
curl -fsSL https://raw.githubusercontent.com/qinyan-ai/qinyan-academic-skills/main/install.sh | bash

# 安装单个 skill
curl -fsSL .../install.sh | bash -s -- --skill scanpy
curl -fsSL .../install.sh | bash -s -- -s academic-paper-search

# 安装分类
curl -fsSL .../install.sh | bash -s -- --category 05
curl -fsSL .../install.sh | bash -s -- -c 01

# 安装到其他工具
curl -fsSL .../install.sh | bash -s -- --tool cursor
curl -fsSL .../install.sh | bash -s -- --tool gemini -s scanpy
curl -fsSL .../install.sh | bash -s -- --tool openclaw
curl -fsSL .../install.sh | bash -s -- --tool openclaw -s scanpy

# 安装到当前项目
curl -fsSL .../install.sh | bash -s -- --project
curl -fsSL .../install.sh | bash -s -- --project -s scanpy
```

### 搜索与浏览命令

```bash
# 搜索 skill
curl -fsSL .../install.sh | bash -s -- --search 蛋白质
curl -fsSL .../install.sh | bash -s -- --search drug

# 列出分类
curl -fsSL .../install.sh | bash -s -- --list

# 列出全部 skills
curl -fsSL .../install.sh | bash -s -- --list-skills
```

### 更新与版本管理命令

```bash
# 检查是否有更新
curl -fsSL .../install.sh | bash -s -- --check-update

# 更新全部
curl -fsSL .../install.sh | bash -s -- --update

# 更新单个 skill
curl -fsSL .../install.sh | bash -s -- --update -s scanpy

# 强制更新（覆盖本地修改）
curl -fsSL .../install.sh | bash -s -- --update --force

# 查看安装状态
curl -fsSL .../install.sh | bash -s -- --status

# 查看脚本版本
curl -fsSL .../install.sh | bash -s -- --version
```

### 本地执行 (git clone 后)

```bash
git clone https://github.com/qinyan-ai/qinyan-academic-skills.git
cd qinyan-academic-skills

bash install.sh                          # 安装全部
bash install.sh --skill scanpy           # 安装单个
bash install.sh --search 论文            # 搜索
bash install.sh --check-update           # 检查更新
bash install.sh --update                 # 更新全部
bash install.sh --update -s scanpy       # 更新单个
bash install.sh --status                 # 查看状态
bash install.sh --help                   # 帮助
```

---

## 设计参考

本版本追踪机制参考了 [clawhub CLI](https://github.com/openclaw/clawhub/blob/main/docs/cli.md) 的设计理念：

| clawhub 概念 | 本项目对应实现 |
|-------------|--------------|
| `.clawhub/lock.json` | `.qinyan-skills/lock.json` |
| `origin.json` (per skill) | lock.json 中的 per-skill 记录 |
| `fingerprint` 检测本地修改 | `compute_fingerprint()` MD5 聚合 |
| `update [slug]` / `update --all` | `--update [-s name]` |
| `--force` 覆盖本地修改 | `--force` / `-f` |
| `list` 查看已安装 | `--status` |
| semver 版本号 | git commit hash 作为版本标识 |

主要区别：clawhub 基于注册中心 (registry API)，本项目基于 git 仓库直接 clone，更轻量、无需账号登录。
