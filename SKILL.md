---
name: academic-paper-search
description: "Multi-source academic paper search skill powered by Academic AI Assistant. Search papers from ArXiv, PubMed, Google Scholar, and Wanfang. Supports basic search, intelligent agent search with reflection-based iteration, and comprehensive paper analysis. Use when user asks to search academic papers, find literature, analyze research papers, or perform literature review."
---

# Academic Paper Search

## Overview

This skill provides powerful academic paper search and analysis capabilities through the Academic AI Assistant API. It supports searching across multiple academic databases (ArXiv, PubMed, Google Scholar, Wanfang) with intelligent filtering, and can perform in-depth paper analysis.

**Triggers:** "paper search", "academic search", "find papers", "literature search", "search arxiv", "search pubmed", "论文搜索", "文献检索", "学术搜索", "论文分析", "paper analysis", "literature review"

## Prerequisites

Before using this skill, ensure:
1. The `ACADEMIC_API_TOKEN` environment variable is set with your Bearer token
2. Network connectivity to the Academic AI Assistant server (47.95.10.101:9000)
3. `curl` and `python3` are available in the environment

**Setup token:**
```bash
export ACADEMIC_API_TOKEN="your-bearer-token-here"
```

## Available Capabilities

### 1. Basic Paper Search (`/v1/paper-search/search`)

Multi-source academic paper search across ArXiv, PubMed, Google Scholar, and Wanfang.

**When to use:** User wants to search for papers with specific keywords, filters by date, author, journal, or source.

**How to use:** Run the search script:

```bash
bash scripts/paper_search.sh '{"query": "deep learning", "total_results": 20}'
```

**Full request parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `query` | string | (required) | Search query keywords |
| `total_results` | int | 120 | Total number of results across all sources |
| `offset_google` | int | 0 | Starting index for Google results |
| `offset_arxiv` | int | 0 | Starting index for ArXiv results |
| `offset_pubmed` | int | 0 | Starting index for PubMed results |
| `page` | int | 1 | Page number (>=1) |
| `date_from` | string | "" | Start date (YYYY-MM-DD) |
| `date_to` | string | "" | End date (YYYY-MM-DD) |
| `author` | string | "" | Filter by author name |
| `journal` | string | "" | Filter by journal name |
| `sort` | string | "" | Sort: "relevance", "newest", "oldest" |
| `language` | string | "" | "English", "中文", or "" for all |
| `sources` | list | null | Filter: ["Google", "ArXiv", "PubMed", "Wanfang"] |

**Example searches:**

Search for recent AI papers:
```bash
bash scripts/paper_search.sh '{"query": "large language model", "total_results": 10, "date_from": "2024-01-01", "sort": "newest"}'
```

Search Chinese papers only:
```bash
bash scripts/paper_search.sh '{"query": "脑机接口", "language": "中文", "sources": ["Wanfang"]}'
```

Search by author:
```bash
bash scripts/paper_search.sh '{"query": "transformer", "author": "Vaswani"}'
```

**Response contains:**
- `success`: whether search succeeded
- `results`: count per source (Google, ArXiv, PubMed, Wanfang, total)
- `data`: array of paper objects with title, authors, abstract, publication_year, doi, source_url, pdf_url, categories, cited_by_count

### 2. Intelligent Agent Search (`/v1/paper-search/agent_search_blocking`)

AI-powered intelligent paper search with reflection-based iteration. The agent understands natural language queries, automatically plans search strategies, applies filters (SCI tier, impact factor, citations, journal labels), and iterates up to 3 times to find the best results.

**When to use:** User provides a natural language research request, wants filtered high-quality papers, needs papers from specific journal tiers (SCI Q1, CSCD, etc.), or wants an AI-generated literature summary.

**How to use:** Run the agent search script:

```bash
bash scripts/agent_search.sh '{"query": "Find 10 SCI Q1 papers on deep learning for medical imaging from the last 3 years", "language": "中文"}'
```

**Request parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `query` | string | (required) | Natural language search query |
| `language` | string | "中文" | Response language: "中文" or "English" |
| `sources` | list | null | Sources: ["google", "arxiv", "pubmed", "wanfang"] |

**Example queries:**

Find high-impact SCI papers:
```bash
bash scripts/agent_search.sh '{"query": "检索SCI一区的大模型算法优化论文10篇", "language": "中文"}'
```

Find papers by a specific author:
```bash
bash scripts/agent_search.sh '{"query": "最近十年何凯明的高质量论文", "language": "中文"}'
```

English language results:
```bash
bash scripts/agent_search.sh '{"query": "Recent advances in protein structure prediction using AI", "language": "English"}'
```

**Supported filter criteria in natural language:**
- Journal labels: CSCD, 北大中文核心, EI, SCI, SSCI, AHCI, CCF, CSSCI
- SCI tiers: Q1/1区, Q2/2区, Q3/3区, Q4/4区
- Impact factor range
- Citation count range
- Date range
- Target paper count (max 50)
- Language preference

**Response contains:**
- `response`: AI-generated literature summary in specified language
- `papers`: array of paper objects with enriched metadata (title, authors, abstract, doi, source_url, pdf_url, labels with journal tiers, impact factor, categories)
- `total_found` / `total_returned`: search statistics
- `iterations_used`: number of search iterations performed
- `filter_applied`: actual filter criteria used
- `plan`: search plan details

### 3. Paper Analysis (`/v1/paper-search/analyze`)

Comprehensive analysis and interpretation of a single academic paper. The system fetches the paper content (via PDF, web, or abstract) and generates a detailed research analysis.

**When to use:** User wants to understand a specific paper, needs a paper summary, or wants detailed analysis of methodology and findings.

**How to use:** Run the analysis script:

```bash
bash scripts/paper_analyze.sh '{"title": "Attention Is All You Need", "authors": ["Vaswani et al."], "doi": "10.48550/arXiv.1706.03762", "language": "中文"}'
```

**Request parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | string | (required) | Paper title |
| `authors` | list | (required) | List of author names |
| `abstract` | string | null | Paper abstract |
| `doi` | string | null | Digital Object Identifier |
| `source_url` | string | null | Paper URL |
| `pdf_url` | string | null | PDF URL |
| `language` | string | "中文" | Output language |

**Note:** At least one of `abstract`, `source_url`, or `pdf_url` must be provided.

**Response contains:**
- `analysis`: structured analysis with research findings, methodology, results
- `content_sources`: sources used for analysis (pdf, web, abstract, web_search)

## Workflow Recommendations

### Literature Review Workflow
1. Start with **Agent Search** for an intelligent, curated set of papers with a natural language query
2. Review the AI-generated summary and paper list
3. Use **Paper Analysis** on the most relevant papers for deep understanding
4. Use **Basic Search** if you need more papers with specific keyword/filter combinations

### Quick Search Workflow
1. Use **Basic Search** with specific keywords for fast results
2. Filter by source, date, author, or journal as needed
3. Use **Paper Analysis** for any paper that needs deeper investigation

## Error Handling

If a script returns an error:
- Check that `ACADEMIC_API_TOKEN` is set: `echo $ACADEMIC_API_TOKEN`
- Verify network connectivity: `curl -s http://47.95.10.101:9000/health`
- Check the error message in the response for details

## Output Formatting

When presenting results to users:
- Display paper titles as bold text
- Include authors, year, journal/source
- Provide DOI links and PDF links when available
- Show abstract (truncated if very long)
- For agent search, present the AI-generated summary first, then the paper list
- Use tables for comparing multiple papers
