# 沁言学术科研论文 Skills 库

[![Skills](https://img.shields.io/badge/Skills-177-brightgreen.svg)](#skills-分类目录)
[![Categories](https://img.shields.io/badge/分类-17-blue.svg)](#skills-分类目录)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Works with](https://img.shields.io/badge/Works_with-Claude_Code_|_Cursor_|_Codex-blue.svg)](#快速开始)

一个面向学术科研的综合性 Skills 集合库，专门收集整理各种学术研究相关的 Agent Skills。所有用户和 Agent 都可以访问并一键安装使用。

本库整合了来自以下优秀开源项目的 Skills：
- [K-Dense-AI/claude-scientific-skills](https://github.com/K-Dense-AI/claude-scientific-skills) — 170+ 科学研究 Skills
- [luwill/research-skills](https://github.com/luwill/research-skills) — 学术论文 Slide、综述写作、研究计划 Skills
- 自研的学术论文搜索 Skill (Academic Paper Search)

---

## Skills 分类目录

| 编号 | 分类 | 数量 | 说明 |
|------|------|------|------|
| 01 | [论文检索与文献管理](#01-论文检索与文献管理) | 11 | 论文搜索、文献检索、引用管理、文献数据库 |
| 02 | [科学写作与学术交流](#02-科学写作与学术交流) | 6 | 论文写作、同行评审、研究计划、综述撰写 |
| 03 | [学术演示与可视化](#03-学术演示与可视化) | 9 | 学术海报、演示文稿、科学示意图、数据可视化 |
| 04 | [研究方法与科学思维](#04-研究方法与科学思维) | 8 | 假设生成、科学头脑风暴、批判性思维、基金申请 |
| 05 | [生物信息与基因组学](#05-生物信息与基因组学) | 21 | 序列分析、单细胞分析、基因调控网络、变异注释 |
| 06 | [化学信息与药物发现](#06-化学信息与药物发现) | 12 | 分子操作、虚拟筛选、分子对接、药物化学 |
| 07 | [临床医学与精准医疗](#07-临床医学与精准医疗) | 18 | 临床试验、变异解读、医学影像、临床决策 |
| 08 | [蛋白质工程与结构生物学](#08-蛋白质工程与结构生物学) | 7 | 蛋白质语言模型、结构预测、序列设计 |
| 09 | [机器学习与人工智能](#09-机器学习与人工智能) | 14 | 深度学习、经典ML、时间序列、贝叶斯方法 |
| 10 | [材料科学与物理计算](#10-材料科学与物理计算) | 10 | 材料分析、量子计算、天文学、流体仿真 |
| 11 | [数据分析与统计建模](#11-数据分析与统计建模) | 11 | 统计分析、网络分析、符号数学、数据可视化 |
| 12 | [科学数据库](#12-科学数据库) | 22 | 蛋白质/化学/基因组/临床等专业数据库 |
| 13 | [实验室自动化与集成](#13-实验室自动化与集成) | 9 | 液体处理、实验室信息管理、工作流自动化 |
| 14 | [文档处理与数据工具](#14-文档处理与数据工具) | 7 | PDF/DOCX/PPTX/XLSX 处理、格式转换 |
| 15 | [金融与经济数据](#15-金融与经济数据) | 6 | SEC 数据、经济数据、市场分析 |
| 16 | [地理空间与遥感](#16-地理空间与遥感) | 2 | GIS 分析、卫星遥感、空间统计 |
| 17 | [平台与基础设施](#17-平台与基础设施) | 4 | 云计算、资源管理、合规认证 |

**总计：177 个 Skills**

---

## 快速开始

### 方式一：一键 Bash 命令安装（推荐，无需 clone）

无需手动克隆仓库，一条命令即可远程安装：

**安装全部 177 个 Skills：**
```bash
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/qinyan-academic-skills/main/install.sh | bash
```

**安装某个分类（按编号）：**
```bash
# 安装 01-论文检索与文献管理（11个skills）
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/qinyan-academic-skills/main/install.sh | bash -s -- --category 01

# 安装 05-生物信息与基因组学（21个skills）
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/qinyan-academic-skills/main/install.sh | bash -s -- -c 05

# 安装 09-机器学习与人工智能（14个skills）
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/qinyan-academic-skills/main/install.sh | bash -s -- -c 09
```

**安装单个 Skill：**
```bash
# 安装学术论文搜索
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/qinyan-academic-skills/main/install.sh | bash -s -- --skill academic-paper-search

# 安装单细胞分析 scanpy
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/qinyan-academic-skills/main/install.sh | bash -s -- -s scanpy

# 安装论文自动生成PPT
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/qinyan-academic-skills/main/install.sh | bash -s -- -s paper-slide-deck

# 安装研究计划撰写
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/qinyan-academic-skills/main/install.sh | bash -s -- -s research-proposal
```

**安装到其他工具（Cursor / Codex / Gemini CLI）：**
```bash
# 安装全部到 Cursor
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/qinyan-academic-skills/main/install.sh | bash -s -- --tool cursor

# 安装生物信息分类到 Gemini CLI
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/qinyan-academic-skills/main/install.sh | bash -s -- -c 05 --tool gemini
```

**安装到当前项目（而非全局）：**
```bash
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/qinyan-academic-skills/main/install.sh | bash -s -- --project
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/qinyan-academic-skills/main/install.sh | bash -s -- --project -s scanpy
```

**搜索和浏览 Skills：**
```bash
# 列出所有分类
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/qinyan-academic-skills/main/install.sh | bash -s -- --list

# 列出全部 Skills
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/qinyan-academic-skills/main/install.sh | bash -s -- --list-skills

# 搜索含 "蛋白质" 的 Skills
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/qinyan-academic-skills/main/install.sh | bash -s -- --search 蛋白质

# 搜索含 "drug" 的 Skills
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/qinyan-academic-skills/main/install.sh | bash -s -- --search drug
```

**查看帮助：**
```bash
curl -fsSL https://raw.githubusercontent.com/LeonChaoX/qinyan-academic-skills/main/install.sh | bash -s -- --help
```

---

### 方式二：Git Clone 手动安装

```bash
git clone https://github.com/LeonChaoX/qinyan-academic-skills.git
cd qinyan-academic-skills

# 安装全部
bash install.sh

# 安装某个分类
bash install.sh --category 01

# 安装单个 skill
bash install.sh --skill scanpy

# 搜索
bash install.sh --search 论文
```

### 方式三：直接复制目录

```bash
git clone https://github.com/LeonChaoX/qinyan-academic-skills.git

# 复制全部
cp -r qinyan-academic-skills/skills/*/* ~/.claude/skills/

# 复制某个分类
cp -r qinyan-academic-skills/skills/01-论文检索与文献管理/* ~/.claude/skills/

# 复制单个 skill
cp -r qinyan-academic-skills/skills/01-论文检索与文献管理/academic-paper-search ~/.claude/skills/
```

### 支持的工具

| 工具 | 全局安装目录 | 项目级安装目录 |
|------|-------------|---------------|
| Claude Code | `~/.claude/skills/` | `.claude/skills/` |
| Cursor | `~/.cursor/skills/` | `.cursor/skills/` |
| Codex | `~/.codex/skills/` | `.codex/skills/` |
| Gemini CLI | `~/.gemini/skills/` | `.gemini/skills/` |

---

## Skills 详细列表

### 01-论文检索与文献管理

| Skill | 说明 |
|-------|------|
| academic-paper-search | 多源学术论文搜索（ArXiv/PubMed/Google Scholar/万方），支持智能Agent搜索和论文分析 |
| bgpt-paper-search | 结构化全文论文搜索（方法、结果、样本量等25+字段） |
| biorxiv-database | bioRxiv 预印本数据库 |
| citation-management | 引用管理工具 |
| literature-review | 文献综述撰写 |
| openalex-database | OpenAlex 学术文献数据库 |
| parallel-web | 并行网络搜索与摘要生成 |
| perplexity-search | AI驱动的实时信息搜索 |
| pubmed-database | PubMed 生物医学文献数据库 |
| pyzotero | Zotero 文献管理Python接口 |
| research-lookup | 研究发现工具 |

### 02-科学写作与学术交流

| Skill | 说明 |
|-------|------|
| medical-imaging-review | 医学影像AI综述写作（7阶段系统化工作流） |
| paper-2-web | 论文转网页发布 |
| peer-review | 同行评审工具 |
| research-proposal | PhD研究计划撰写（支持中英文，Nature Reviews学术写作风格） |
| scientific-writing | 科学论文写作 |
| venue-templates | 学术会议/期刊模板 |

### 03-学术演示与可视化

| Skill | 说明 |
|-------|------|
| generate-image | AI图像生成（FLUX.2 Pro） |
| infographics | 专业信息图表制作（10类型，8风格） |
| latex-posters | LaTeX学术海报 |
| markdown-mermaid-writing | Mermaid流程图与文档 |
| paper-slide-deck | 论文自动生成演示文稿（17种视觉风格，自动提取图表） |
| pptx-posters | PPTX学术海报 |
| scientific-schematics | 科学示意图绘制 |
| scientific-slides | 科学报告幻灯片 |
| scientific-visualization | 科学数据可视化 |

### 04-研究方法与科学思维

| Skill | 说明 |
|-------|------|
| consciousness-council | 多视角专家讨论与分析 |
| dhdna-profiler | 认知模式与思维特征分析 |
| hypothesis-generation | 科学假设生成 |
| research-grants | 基金申请写作 |
| scholar-evaluation | 学者评估 |
| scientific-brainstorming | 科学头脑风暴 |
| scientific-critical-thinking | 科学批判性思维 |
| what-if-oracle | 多分支可能性探索与风险分析 |

### 05-生物信息与基因组学

| Skill | 说明 |
|-------|------|
| anndata | 单细胞数据结构 |
| arboreto | 基因调控网络推断 |
| biopython | 生物序列分析 |
| bioservices | 生物信息Web服务（40+数据源） |
| cellxgene-census | 单细胞数据集 |
| deeptools | 深度测序分析 |
| etetoolkit | 进化树分析 |
| flowio | 流式细胞术数据处理 |
| geniml | 基因组机器学习 |
| gget | 基因组数据获取（20+数据库） |
| gtars | 基因组区域分析 |
| lamindb | 生物数据管理 |
| phylogenetics | 系统发育分析 |
| pydeseq2 | 差异表达分析 |
| pysam | SAM/BAM文件处理 |
| scanpy | 单细胞RNA-seq分析 |
| scikit-bio | 生物信息统计 |
| scvelo | RNA速率分析 |
| scvi-tools | 单细胞变分推断 |
| tiledbvcf | VCF变异数据库管理 |
| zarr-python | 大规模数组存储 |

### 06-化学信息与药物发现

| Skill | 说明 |
|-------|------|
| datamol | 分子数据处理 |
| deepchem | 药物发现深度学习 |
| diffdock | 分子对接预测 |
| matchms | 质谱匹配 |
| medchem | 药物化学分析 |
| molecular-dynamics | 分子动力学模拟 |
| molfeat | 分子特征提取 |
| pyopenms | 质谱数据处理 |
| pytdc | 药物发现基准测试 |
| rdkit | 化学信息学工具包 |
| rowan | 云端量子化学计算 |
| torchdrug | 药物发现图神经网络 |

### 07-临床医学与精准医疗

| Skill | 说明 |
|-------|------|
| cbioportal-database | 癌症基因组数据库 |
| clinical-decision-support | 临床决策支持 |
| clinical-reports | 临床报告生成 |
| clinicaltrials-database | 临床试验数据库 |
| clinpgx-database | 药物基因组学数据库 |
| clinvar-database | 变异致病性数据库 |
| cosmic-database | 癌症体细胞突变数据库 |
| depmap | 癌细胞系依赖性数据 |
| fda-database | FDA药物数据库 |
| histolab | 组织病理学分析 |
| imaging-data-commons | 医学影像数据库 |
| monarch-database | 罕见病数据库 |
| neurokit2 | 生理信号处理 |
| neuropixels-analysis | 神经电生理分析 |
| pathml | 数字病理学 |
| pydicom | DICOM影像处理 |
| pyhealth | 健康AI工具 |
| treatment-plans | 治疗方案设计 |

### 08-蛋白质工程与结构生物学

| Skill | 说明 |
|-------|------|
| adaptyv | 蛋白质自动化测试平台 |
| alphafold-database | AlphaFold蛋白质结构数据库 |
| esm | 蛋白质语言模型 |
| glycoengineering | 糖基化工程 |
| interpro-database | 蛋白质结构域数据库 |
| pdb-database | 蛋白质结构数据库 |
| uniprot-database | 蛋白质序列数据库 |

### 09-机器学习与人工智能

| Skill | 说明 |
|-------|------|
| aeon | 时间序列分析 |
| hypogenic | 假设驱动的AI |
| pymc | 贝叶斯统计建模 |
| pymoo | 多目标优化 |
| pufferlib | 强化学习 |
| pytorch-lightning | PyTorch训练框架 |
| scikit-learn | 经典机器学习 |
| scikit-survival | 生存分析 |
| shap | 模型可解释性 |
| stable-baselines3 | 强化学习算法 |
| timesfm-forecasting | 时间序列预测（Google零样本模型） |
| torch-geometric | 图神经网络 |
| transformers | Transformer模型 |
| umap-learn | 降维可视化 |

### 10-材料科学与物理计算

| Skill | 说明 |
|-------|------|
| astropy | 天文学计算 |
| cirq | Google量子电路 |
| cobrapy | 代谢建模 |
| fluidsim | 计算流体力学 |
| matlab | MATLAB/Octave数值计算 |
| pennylane | 量子机器学习 |
| pymatgen | 材料科学分析 |
| qiskit | IBM量子计算 |
| qutip | 量子系统模拟 |
| simpy | 离散事件仿真 |

### 11-数据分析与统计建模

| Skill | 说明 |
|-------|------|
| dask | 分布式计算 |
| exploratory-data-analysis | 探索性数据分析 |
| matplotlib | 绘图库 |
| networkx | 网络/图分析 |
| plotly | 交互式可视化 |
| polars | 高性能数据框 |
| seaborn | 统计数据可视化 |
| statistical-analysis | 统计分析工作流 |
| statsmodels | 统计建模 |
| sympy | 符号数学计算 |
| vaex | 大数据懒计算 |

### 12-科学数据库

| Skill | 说明 |
|-------|------|
| bindingdb-database | 药物-靶标结合亲和力 |
| brenda-database | 酶学数据库 |
| chembl-database | 生物活性分子数据库 |
| datacommons-client | Google数据公共资源 |
| drugbank-database | 药物信息数据库 |
| ena-database | 欧洲核酸数据库 |
| ensembl-database | 基因组注释数据库 |
| gene-database | NCBI基因数据库 |
| geo-database | 基因表达数据库 |
| gnomad-database | 群体等位基因频率 |
| gtex-database | 组织特异性表达 |
| gwas-database | 全基因组关联研究 |
| hmdb-database | 人类代谢组数据库 |
| jaspar-database | 转录因子结合位点 |
| kegg-database | 通路与基因组数据库 |
| metabolomics-workbench-database | 代谢组学数据库 |
| opentargets-database | 药物靶标数据库 |
| pubchem-database | 化学分子数据库 |
| reactome-database | 生物通路数据库 |
| string-database | 蛋白质互作网络 |
| uspto-database | 美国专利数据库 |
| zinc-database | 可购买化合物数据库 |

### 13-实验室自动化与集成

| Skill | 说明 |
|-------|------|
| benchling-integration | Benchling实验室平台 |
| dnanexus-integration | DNAnexus基因组分析平台 |
| ginkgo-cloud-lab | 合成生物学云实验室 |
| labarchive-integration | LabArchives电子实验记录 |
| latchbio-integration | LatchBio生物信息平台 |
| omero-integration | 显微镜影像管理 |
| opentrons-integration | Opentrons液体处理 |
| protocolsio-integration | Protocols.io实验方案 |
| pylabrobot | Python实验室机器人 |

### 14-文档处理与数据工具

| Skill | 说明 |
|-------|------|
| denario | 研究数据分析流水线 |
| docx | Word文档处理 |
| markitdown | 文件格式转Markdown |
| open-notebook | 开源NotebookLM替代方案 |
| pdf | PDF文档处理 |
| pptx | PowerPoint处理 |
| xlsx | Excel表格处理 |

### 15-金融与经济数据

| Skill | 说明 |
|-------|------|
| alpha-vantage | 全球市场数据（股票/外汇/加密货币） |
| edgartools | SEC财务数据 |
| fred-economic-data | 美联储经济数据（80万+时间序列） |
| hedgefundmonitor | 对冲基金系统性风险监控 |
| market-research-reports | 市场研究报告 |
| usfiscaldata | 美国联邦财政数据 |

### 16-地理空间与遥感

| Skill | 说明 |
|-------|------|
| geopandas | 地理空间数据分析 |
| geomaster | 遥感/GIS/卫星影像/空间ML（500+示例） |

### 17-平台与基础设施

| Skill | 说明 |
|-------|------|
| get-available-resources | 可用资源检测 |
| iso-13485-certification | 医疗器械ISO认证 |
| modal | Modal云计算平台 |
| offer-k-dense-web | K-Dense Web平台 |

---

## 致谢

本项目整合了以下优秀的开源项目，在此表示感谢：

- **[K-Dense-AI/claude-scientific-skills](https://github.com/K-Dense-AI/claude-scientific-skills)** — 由 K-Dense Inc. 维护的 170+ 科学研究 Skills 集合
- **[luwill/research-skills](https://github.com/luwill/research-skills)** — 学术论文演示、综述写作和研究计划相关 Skills

---

## 贡献

欢迎提交 Pull Request 来扩展和改进本 Skills 库！

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/new-skill`)
3. 将新 Skill 放入对应的分类目录下
4. 确保包含完整的 `SKILL.md` 文件
5. 提交 Pull Request

---

## License

MIT License - 详见 [LICENSE](LICENSE) 文件

> 注意：每个 Skill 可能有自己的许可证，详见各 Skill 的 `SKILL.md` 文件中的 `license` 字段。
