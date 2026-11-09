---
name: paper-workflow
description: 心理学与教育类论文批量写作流水线。两条线：12 篇项目（papers/，APA 7）与课程作业（assignments/作业N_，GB/T 7714 或作业指定模版）。两阶段交付：先出「框架 + 文献清单（引用经 Crossref/OpenAlex/arXiv 或中文期刊页面核验，含逐字原文摘录）」，用户确认后才写全文；全文写完必须过「自查门」（AIGC 套路句、英文翻译腔、年份与文献一致性）。Use when 用户提到「写论文」「第 N 篇」「作业N」「拿到要求了」「按流程做论文」「降 AIGC」「自查」，或给出论文要求/模版/字数/选题需要落成稿时。
---

# 论文流水线（12 篇项目 + 作业支线）

## 0. 先判断走哪条线

| 用户说法 | 线路 | 根目录 | 手册 |
|---|---|---|---|
| 「作业N」「根据 作业N.md 做论文」 | 作业支线 | `/Users/101bjb0413/Desktop/work/tmp/assignments/` | `references/assignments.md` |
| 「第 N 篇」「12 篇项目」 | 项目线 | `/Users/101bjb0413/Desktop/work/tmp/papers/` | `references/pipeline.md` |

两条线共用：两阶段闸门、引用核验、逐字摘录、**自查门**、文风门。作业支线不要混进 `papers/`。

## 1. 铁律（违反任何一条即返工）

1. **两阶段闸门**：框架 + 文献清单先交付，等用户确认才写全文。不要顺手把全文写完。
2. **不凭记忆写引用**。英文文献来自 Crossref / OpenAlex / arXiv / PubMed 的可复查记录；中文文献来自知网 / 万方 / 期刊官网的**文章页**（记录 URL + 访问日期），状态记为 `verified_cn_*`。
3. **「DOI 能解析」不算核验通过**。标题 + 一作 + 年份三项必须对上，状态才是 `verified`。
4. **原文摘录必须逐字命中全文**，`check_quotes.py` 退出码 0 才能交付。拿不到全文就标「仅摘要级」，**绝不拿摘要臆造原文**。
5. **不编数据**。被试、样本量、统计结果只能来自文献原文或用户提供的数据。
6. **没有全文的文献不得做具体结论断言**，不为让论文「看起来完整」而引用没读过的文献。
7. **全文不出现问号**（标题、摘要、正文、结论都不许有 `？`/`?`），问句改陈述句。`check_paper_rules.py` 会拦。
8. **同一段内同一文献只引一次**，跨段可以重复引用。`check_paper_rules.py` 会拦。
9. **参考文献可按用户要求「全部中文」**：条数、年限、「知网可查」按用户给定值执行（如 12 篇：10 篇期刊 + 2 篇学位论文），按 `references/cnki.md` 页面核验。
10. **文风参考人类样本时**：按 `references/human-style-grassland.md` 的画像写作，并跑 `check_style.py --profile review`（14 项全过）。**风格可学，原句不可抄；数字只能来自文献原文。**
11. **引用格式跟用户给的模板走**：用户指定「引用格式模板」时先按 `references/citation-format.md` 拆解，再落地；**只改引用格式，不顺手改别的**。
12. **自查门必须过（新增）**：写完正文，先跑 `check_selfcheck.py`，HARD 为 0 才能渲染交付。命中的套路句必须改写，不能只换同义词。细则见 `references/self-check.md`。
13. **英文摘要不得逐句对译中文**，按英文学术写法重写；词数、关键词数按要求执行。
14. **年份范围与参考文献一致**：正文写「2021—2025 年」，参考文献最晚就要是 2025；写的年份不能超过文献实际年份（自查 S6 会拦）。

## 2. 工作流

```
阶段0 看板 → 阶段1 框架 + 文献清单（等用户确认）→ 阶段2 写 paper.md
→ 阶段2.5 自查循环（check_selfcheck + check_paper_rules + check_style）
→ 渲染 docx → 复验 docx（自查 + 结构断言）→ 交付 + 更新看板
```

| 阶段 | 产物 | 闸门 |
|---|---|---|
| 0 看板 | `INDEX.md` 查状态，建目录（`new_assignment.py` / `new_paper.py`） | — |
| 1 框架与文献 | `作业N_01_框架.md`、`作业N_02_文献清单.md`、`作业N_参考文献.md` | 核验 + 摘录 + 框架↔清单 citekey 双向比对；**等用户确认** |
| 2 写作 | `作业N_paper.md` | — |
| 2.5 自查 | 自查报告（json）+ 改稿 | **HARD=0、规则 9 项全过、文风 14 项全过** |
| 3 渲染 | `作业N_论文.docx` | 结构断言 50 项；docx 再跑一次自查 |
| 4 交付 | 看板状态改「定稿」；交付说明列出自查结果与修改摘要 | 用户确认后才算完成 |

字数、引用、模版等默认值见第 6 节；项目线的具体命令见 `references/pipeline.md`。

## 3. 自查门（新增，2026-11 固化）

依据：某篇作业经大雅 AIGC 检测为 8.32%，重度疑似集中在中英文摘要（45.94%），引言若干段为轻度疑似。**原稿的文风体检 14 项全部通过，但仍被标记**，说明统计画像不能代替句式自查。

```bash
PY=/Users/101bjb0413/.dsh/dsh-runtimes/dsh-primary-runtime/dependencies/python/bin/python3
cd /Users/101bjb0413/Desktop/work/tmp/assignments/作业N_<短名>
$PY ../_shared/check_selfcheck.py --md 作业N_paper.md          # 0=通过（WARN 不阻断，但逐条判断）
$PY ../_shared/check_selfcheck.py --docx 作业N_论文.docx        # 渲染后再查一次
```

- 硬性规则 S1–S6：承接套话、对举句式、无据断言、英文翻译腔、破折号/问号、年份与文献不一致。
- 警告 W1–W6：金句收束、既…也、一方面…另一方面、开场套话、长句链（≥200 字）、整齐枚举。
- 修复循环、改写示例、引用不变性核对：见 `references/self-check.md`。

## 4. 目录约定

```
papers/                         # 12 篇项目
  INDEX.md                      # 看板（唯一真相）
  _shared/pipeline/             # 项目级脚本
  _template/                    # 新论文骨架
  01_growth-mindset/            # 样例（照它的颗粒度做）

assignments/                    # 课程作业（固定根目录，不要另起名字）
  INDEX.md                      # 作业看板（唯一真相）
  _shared/
    new_assignment.py           # 建作业目录
    gbt_refs.py                 # GB/T 7714 参考文献（中英文混排）
    verify_cn.py / harvest_cn.py# 中文文献核验 / 候选发现
    render_zuoye_docx.py        # 作业版式 docx（--ref-style gbt|template，--cover）
    check_paper_rules.py        # 规则：无问号 / 段内不重复 / 全中文 / 编号
    check_style.py              # 文风体检 14 项（统计画像）
    check_selfcheck.py          # 自查门（套路句 / 翻译腔 / 年份一致）★新增
    pipeline -> ../../papers/_shared/pipeline
  作业N_<中文短名>/
    作业N_00_要求与模版.md  作业N_01_框架.md  作业N_02_文献清单.md
    作业N_参考文献.md  作业N_paper.md  作业N_论文.docx
    work/pool/  work/texts/  work/original/   # 改稿前版本备份放 work/original/
```

- 所有交付文件名以 `作业N_` 开头（用户靠前缀定位）。
- 改稿前先把旧版备份到 `work/original/`，便于对比与回滚。
- 新论文复制 `01_growth-mindset` 的格式，不要自创结构。

## 5. 作业支线要点

1. 目录名固定 `作业N_<中文短名>`；建目录只用 `_shared/new_assignment.py`。
2. 引用格式跟作业要求走：作业用 `[1]` 顺序编码制 → GB/T 7714（`gbt_refs.py`）；用户指定模版（如「小论文草地恢复_终版_230903.docx」）时按 `references/citation-format.md` 落地，`--style template` / `--ref-style template`。作业没要求时默认 APA 7。
3. 标题用陈述句，不要问句。
4. 排版用 `render_zuoye_docx.py`，**不要**用 `render_docx.py`（那是 APA 7 双倍行距版式）。封面要求「参照某校研究生院课程论文封面」时加 `--cover`。
5. 用户要求「参考文献全部为中文、知网可查、近 5 年、N 篇」时严格按 N 条交付，不掺英文文献；交付前跑 `check_paper_rules.py --refs N --all-chinese --min-chars 3000`。
6. 正文写完后依次跑：**自查门 → 规则检查 → 文风门 → 渲染 → docx 复验**，任何一步不过不交付。
7. 手册：`references/assignments.md`。

## 6. 输入不全时怎么办

不要反复追问。按默认值先做，并在交付物顶部用表格写明「采用的默认值 + 改动成本」：

| 项 | 默认值 |
|---|---|
| 字数 | 正文 N 字，不含摘要与参考文献 |
| 语言 | 中文行文 + 英文标题/Abstract/Keywords（作业要求中英文时） |
| 类型 | 文献综述型（无数据就不做实证） |
| 引用 | 作业按 GB/T 7714 或模版；项目线按 APA 7 |

缺项只问这 4 个：字数口径、语言、综述/实证、模版。

## 7. 环境事实（不要重新试错）

- 学术 API 可用：Crossref / OpenAlex / arXiv / PubMed / Europe PMC；Semantic Scholar 可达但常 429。
- 项目级 skill 目录：`/Users/101bjb0413/Desktop/work/tmp/.dsh/skills`。
- `python3` 系统解释器缺 `docx/requests/pandas`；**必须用** `/Users/101bjb0413/.dsh/dsh-runtimes/dsh-primary-runtime/dependencies/python/bin/python3`。
- 全文抓取：OA 期刊、机构库、PsyArXiv、PMC（经 Europe PMC JATS XML）可得；Wiley/Elsevier/SAGE 直链多为 403。
- 中文文献：知网检索接口在本机全不可用；**Magtech 期刊官网**（心理发展与教育 / 心理科学 / 华东师大学报教育科学版 / 心理科学进展 / 心理学报）的检索与文章页可直接抓。详见 `references/cnki.md` 第 6.5 节。
- 本机无「宋体/黑体」字体，LibreOffice 预览会报 missingFonts；当前模型不能读图，**视觉排版不做人眼断言**，只做结构属性断言。
- 原始 zip 解压时若报 `Operation not permitted`，改用 Python `zipfile` 解到 `/tmp` 下处理文件名编码。

## 8. 手册索引

- `references/self-check.md` — **自查手册**：检查项、修复循环、改写示例、边界（新增）
- `references/assignments.md` — 作业支线的目录、命令、验收、已知坑
- `references/pipeline.md` — 项目线 10 个脚本的命令、参数、已知坑
- `references/deliverables.md` — 交付物格式与验收命令
- `references/request-template.md` — 用户如何提要求（可复制的话术）
- `references/cnki.md` — 中文知网文献检索、页面核验与 GB/T 7714 著录
- `references/citation-format.md` — 引用格式模板拆解（上标引用、英文对照、9pt、0.5in 悬挂）
- `references/human-style-grassland.md` — 人类文风档案与 `check_style.py` 阈值
