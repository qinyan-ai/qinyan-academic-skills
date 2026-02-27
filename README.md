# Academic Paper Search Skill

A powerful academic paper search and analysis skill for [Claude Code](https://claude.ai/claude-code) / [OpenClaw](https://openclaw.ai). Search across ArXiv, PubMed, Google Scholar, and Wanfang databases with intelligent AI-powered filtering and analysis.

## Features

- **Multi-source Search**: Search across ArXiv, PubMed, Google Scholar, and Wanfang simultaneously
- **Intelligent Agent Search**: AI-powered search with natural language queries, automatic strategy planning, and reflection-based iteration (up to 3 rounds)
- **Advanced Filtering**: Filter by SCI tier (Q1-Q4), impact factor, citations, journal labels (CSCD, EI, SSCI, etc.)
- **Paper Analysis**: Comprehensive analysis of individual papers including methodology, findings, and contributions
- **Bilingual Support**: Full support for Chinese (中文) and English queries and responses

## Quick Install

**One-command install (global):**

```bash
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/academic-paper-search-skill/main/install.sh | bash
```

**Install to current project only:**

```bash
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/academic-paper-search-skill/main/install.sh | bash -s -- --project
```

**Manual install:**

```bash
# Global install (available to all projects)
git clone https://github.com/LeonChaoX/academic-paper-search-skill.git ~/.claude/skills/academic-paper-search

# Project install (current project only)
git clone https://github.com/LeonChaoX/academic-paper-search-skill.git .claude/skills/academic-paper-search
```

## Setup

Set your API Bearer token:

```bash
export ACADEMIC_API_TOKEN="your-bearer-token-here"

# Add to shell profile for persistence
echo 'export ACADEMIC_API_TOKEN="your-token"' >> ~/.bashrc
```

Verify connectivity:

```bash
curl -s http://47.95.10.101:9000/health
# Expected: {"status": "ok"}
```

## Usage

Once installed, simply talk to Claude Code / OpenClaw naturally:

### Basic Paper Search

> "Search for papers about transformer architecture"
>
> "Find papers by Yann LeCun published after 2020"
>
> "搜索关于脑机接口的论文"

### Intelligent Agent Search

> "Find 10 SCI Q1 papers on deep learning for medical imaging from the last 3 years"
>
> "检索SCI一区的大模型算法优化论文10篇"
>
> "最近十年何凯明的高质量论文"
>
> "帮我查找影响因子大于5的生物信息学英文文献"

### Paper Analysis

> "Analyze the paper 'Attention Is All You Need'"
>
> "分析这篇论文的方法论和创新点"

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/paper-search/search` | POST | Basic multi-source paper search |
| `/v1/paper-search/agent_search_blocking` | POST | AI-powered intelligent search |
| `/v1/paper-search/agent_search` | POST | Streaming intelligent search (SSE) |
| `/v1/paper-search/analyze` | POST | Comprehensive paper analysis |

## Script Usage

You can also use the scripts directly:

```bash
# Basic search
bash ~/.claude/skills/academic-paper-search/scripts/paper_search.sh \
  '{"query": "deep learning", "total_results": 10, "sort": "newest"}'

# Intelligent agent search
bash ~/.claude/skills/academic-paper-search/scripts/agent_search.sh \
  '{"query": "Find SCI Q1 papers on LLM", "language": "English"}'

# Paper analysis
bash ~/.claude/skills/academic-paper-search/scripts/paper_analyze.sh \
  '{"title": "BERT", "authors": ["Devlin"], "doi": "10.48550/arXiv.1810.04805", "language": "English"}'
```

## Supported Sources

| Source | Database | Coverage |
|--------|----------|----------|
| Google | Google Scholar | Broad academic coverage |
| ArXiv | arXiv.org | Preprints (CS, Physics, Math, etc.) |
| PubMed | PubMed/MEDLINE | Biomedical and life sciences |
| Wanfang | 万方数据 | Chinese academic literature |

## Supported Journal Labels

SCI, SSCI, AHCI, EI, CSCD, CCF, 北大中文核心, 中国科技核心, CSSCI, 中科院

## Requirements

- `curl` - HTTP client
- `python3` - JSON processing
- Network access to `47.95.10.101:9000`

## License

MIT
