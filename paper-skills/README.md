# 论文 / 科研 Skill 合集（22 个）

一套可直接放进 AI Agent（DeepSeek Harness / Claude Code 等）`skills/` 目录的科研与论文写作技能包。
每个 skill 是一个独立文件夹，核心是 `SKILL.md`（给模型看的操作手册），复杂技能还带 `references/` 细则和 `scripts/` 可运行脚本。

- **21 个通用学术 skill**：覆盖选题 → 文献检索 → 引用核验 → 写作 → 格式 → 审稿 → 复现声明全流程，干净自包含，换台机器就能用。
- **1 个个人流水线 skill**：`paper-workflow`，心理学 / 教育类论文批量写作流水线（两阶段交付 + 引用核验 + 自查门）。**内含原作者本机的绝对路径和目录假设，别人要用需先改路径**，详见第 4 节。

---

## 1. 安装

Skill 的通用约定是：**一个目录一个技能，目录里有 `SKILL.md`**。

```bash
# DeepSeek Harness（本机路径）
mkdir -p ~/.dsh/skills && cp -R ./skills/* ~/.dsh/skills/

# Claude Code
mkdir -p ~/.claude/skills && cp -R ./skills/* ~/.claude/skills/

# 其他 Agent：放进它的 skills 目录，或直接把某个 SKILL.md 的内容读给它
```

也可以只装自己需要的：

```bash
cp -R ./skills/{paper-lookup,citation-verification,apa7,scientific-writing} ~/.dsh/skills/
```

装完在新会话里说一句「用 scientific-writing 帮我改这段引言」之类，Agent 就会加载对应 skill。部分客户端需要重启或刷新技能列表。

## 2. 环境依赖

大多数 skill 只读 `SKILL.md` 就能用，**不装任何东西也能跑**；带 `scripts/` 的技能需要 Python：

| 依赖 | 用途 | 是否必需 |
|---|---|---|
| Python 3.9+ | 运行 `scripts/*.py` | 带脚本的技能需要 |
| `requests` | 调 Crossref / OpenAlex / PubMed / arXiv 等公开 API | 检索、引用核验类需要 |
| `numpy`、`pandas` | 数据处理、统计功效模拟 | `statistical-power`、`literature-review` 等 |
| `statsmodels` | 部分功效/统计脚本 | 可选 |
| 网络 | 学术 API 查询（多数免费，Crossref 建议设 `CROSSREF_MAILTO`） | 检索类需要 |
| LaTeX / Pandoc | `venue-templates` 的模板编译、`apa7` 的 CSL 路线 | 可选 |
| Zotero + Web API key | `pyzotero` 读写文献库 | 可选 |
| MinerU | `pdf-converter` 的 PDF 解析 | 可选 |

一行装齐：

```bash
python3 -m pip install requests numpy pandas statsmodels
```

## 3. 技能索引

### 写作与成稿

| Skill | 作用 |
|---|---|
| `scientific-writing` | 起草 / 修订 / 审查科研稿件：证据溯源、报告规范（CONSORT/PRISMA 等）、IMRaD 结构、图表、合著与保密、期刊政策 |
| `abstract-and-title` | 标题、结构化/非结构化摘要、关键词、highlights、significance statement、图文摘要、通俗摘要 |
| `unslop-academic-writing` | 去 AI 味 / 学术文风清洗：套路词、空强调、重叠模糊限制语、模板化过渡、破折号堆叠、节奏单调 |
| `venue-templates` | 期刊 / 会议 / 海报 / 基金模板与 LaTeX 脚手架，匿名与页数规则，投稿前 PDF 检查 |
| `apa7` | APA 第 7 版：学生版 vs 专业版、标题页、摘要关键词、标题层级、文内引用、参考文献条目、表格图、无偏见语言、LaTeX/Word/Pandoc 落地 |
| `reproducibility-statement` | 数据与代码可用性声明、复现清单（NeurIPS/ICML/ICLR/Nature 等）、研究产物打包（Zenodo DOI、CITATION.cff、环境锁、随机种子）、伦理与 AI 使用声明、CRediT |

### 选题、设计与统计

| Skill | 作用 |
|---|---|
| `scientific-brainstorming` | 证据感知的科研选题发散：独立生成、结构化讨论、假设显式化、对抗性评审、决策日志 |
| `hypothesis-generation` | 把观察变成可检验假设：候选假设、竞争解释、判别性预测、测量方案、预注册脚手架 |
| `experimental-design` | 数据收集**之前**的实验设计：随机化、区组、因子/部分因子设计、筛选与响应面、交叉/重复测量/裂区、序贯与自适应设计 |
| `statistical-power` | 样本量与统计功效：先验功效分析、最小可检测效应、功效曲线、闭式公式与蒙特卡洛模拟、预注册/伦理申请依据 |
| `scientific-critical-thinking` | 证据质量评估：设计效度、偏倚与混杂、GRADE / Cochrane 风险偏倚等分级框架 |

### 文献、引用与文献库

| Skill | 作用 |
|---|---|
| `paper-lookup` | 一次查 18 个学术 API：PubMed、PMC、Europe PMC、bioRxiv、medRxiv、arXiv、OpenAlex、Crossref、Semantic Scholar、CORE、Unpaywall、OpenCitations、PubTator3、Zenodo、Figshare、ROR、BioStudies、DOAJ，可复现provenance |
| `literature-review` | 系统性文献综述：PubMed/arXiv/bioRxiv/Semantic Scholar 检索、筛选、数据提取、主题综合、引用核验，输出 Markdown + PDF 与 PRISMA 流程图 |
| `systematic-review-prisma` | PRISMA 2020 全流程：PROSPERO/OSF 方案、可复现检索式、去重、标题摘要与全文筛选、偏倚评估、流程图与清单 |
| `citation-management` | DOI/PMID/PMCID/arXiv/URL → BibTeX，OpenAlex/PubMed/Google Scholar 检索，格式化、去重、校验 `.bib` |
| `citation-verification` | 逐条核验参考文献是否真实存在且元数据对得上：抓幻觉引用、DOI 指向错论文、缺失 DOI，投稿前必跑 |
| `bibtex-hygiene` | BibTeX/BibLaTeX 体检与规范化：重复键与重复条目、缺字段、坏 DOI、缩写被吃（`bert`→`BERT`）、页码破折号、arXiv 转正式版、biber 告警 |
| `reference-manager-interop` | 文献库互通：Zotero / Mendeley / EndNote / JabRef / Paperpile ↔ RIS / BibTeX / CSL-JSON，LaTeX/Word/Google Docs/Pandoc/Quarto/Overleaf 联动，CSL 样式选择 |
| `pyzotero` | 用 Python + Zotero Web API v3 读写文献库：条目、分类、标签、附件、保存检索、全文、BibTeX/CSL-JSON 导出，含 CLI 与 MCP |

### 审稿、文档与流水线

| Skill | 作用 |
|---|---|
| `peer-review` | 有依据、建设性的同行评审稿与结构化评估：报告规范选择、论断-证据核对、方法/统计/可复现/伦理/图表/引用批评、回复审稿意见规划 |
| `pdf-converter` | 基于 MinerU 的 PDF 转换：PDF → Word / Markdown / HTML / LaTeX / 纯文本，图片 OCR、扫描件识别、Office 格式互转，80+ 语言 |
| `paper-workflow` | 个人版心理学 / 教育论文流水线：12 篇项目（APA 7）与课程作业（GB/T 7714 或指定模板）两条线；两阶段交付（先框架+文献清单，确认后写全文）；引用核验 + 逐字摘录 + 自查门（AIGC 套路句、翻译腔、年份一致性）。**见第 4 节** |

## 4. 关于 `paper-workflow`（原作者个人流水线）

这个 skill 是原作者按自己的目录结构固化的，**不是开箱即用的通用件**。拿去用之前要改这几处：

1. **绝对路径**：`SKILL.md` 和 `references/*.md` 里出现大量 `/Users/101bjb0413/Desktop/work/tmp/...`，要替换成你自己的论文根目录。
2. **目录假设**：默认存在 `papers/`（12 篇项目线）和 `assignments/作业N_xxx/`（作业线），以及看板 `INDEX.md`。
3. **配套脚本未随包附带**：流水线调用的 `_shared/` 检查脚本（`check_selfcheck.py`、`check_paper_rules.py`、`check_style.py`、`check_quotes.py`、`gbt_refs.py`、`render_zuoye_docx.py`、`new_assignment.py` 等）在原作者工作区的 `assignments/_shared/` 下，**不在本压缩包里**，需要向原作者索取或自己重写。
4. **其中规则仍然有价值**：两阶段闸门、不凭记忆写引用、DOI 可解析 ≠ 核验通过（标题+一作+年份要三项对上）、原文摘录逐字命中、不编数据、同段不重复引同一文献、写完必过自查门 —— 这些方法论对中文论文写作普遍适用，可以直接借。

其余 21 个 skill 相互独立，不依赖 `paper-workflow`。

## 5. 快速试手

装好之后可以这样开口（中文英文都行）：

- 「帮我查 2020 年后关于教师期望与学生学业发展的实证研究，给我带 DOI 的清单」→ `paper-lookup`
- 「把这 30 条参考文献逐条核验，标出对不上和可能是编的」→ `citation-verification`
- 「按 APA 7 学生版格式重排这篇论文的参考文献」→ `apa7`
- 「这段摘要太像 AI 写的，帮我改成学术但有人味的表达」→ `unslop-academic-writing`
- 「我要做 2×3 混合设计，每组 30 人够不够？做功效分析」→ `experimental-design` + `statistical-power`
- 「按 PRISMA 2020 帮我搭一个系统综述的筛选流程」→ `systematic-review-prisma`

## 6. 来源与许可

- 21 个通用 skill 的 `license` 字段（见各 `SKILL.md` 头部 YAML）为 MIT，可自由使用、修改、再分发，保留出处即可。
- `paper-workflow` 为原作者自用整理，随包分享给同行参考；其中引用的第三方文献、模板、期刊页面版权归各自权利人。
- 所有检索类 skill 只调用公开学术 API，请遵守各平台的使用条款与频率限制（Crossref 建议设置 `CROSSREF_MAILTO` 邮箱）。

---

打包日期：2026-11-09
