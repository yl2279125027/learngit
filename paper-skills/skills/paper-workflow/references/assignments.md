# 作业类论文（作业N）手册

> 课程作业论文走这条支线。根目录**固定** `/Users/101bjb0413/Desktop/work/tmp/assignments/`，
> 与 `papers/` 的 12 篇项目完全分开。不要另起目录名。

## 0. 目录与命名（固化规则）

```
assignments/
  INDEX.md                                  # 作业看板（唯一真相）
  _shared/new_assignment.py                 # 建目录
  _shared/gbt_refs.py                       # GB/T 7714 参考文献串（中英文混排，机器生成）
  _shared/verify_cn.py                      # 中文文献页面核验（知网/万方/期刊官网）
  _shared/harvest_cn.py                     # 中文文献候选发现（尽力而为）
  _shared/render_zuoye_docx.py              # 按作业字体字号渲染 docx
  _shared/check_paper_rules.py              # 三条硬规则检查（无问号/段内不重复/全中文）
  _shared/check_style.py                    # 人类文风体检（14 项统计特征）
  _shared/pipeline -> ../../papers/_shared/pipeline
  作业N_<中文短名>/
    作业N_00_要求与模版.md
    作业N_01_框架.md
    作业N_02_文献清单.md
    作业N_参考文献.md                       # GB/T 7714（或作业要求的格式）
    作业N_paper.md                          # 阶段 2
    作业N_论文.docx                         # 阶段 2 交付
    work/pool/  work/texts/
```

- 目录名：`作业N_<中文短名>`
- **所有交付文件名以 `作业N_` 开头**（用户靠前缀定位）
- 阶段 1 交付 = `作业N_01_框架.md` + `作业N_02_文献清单.md` + `作业N_参考文献.md`，**等用户确认**
- 阶段 2 = `作业N_paper.md` → `作业N_论文.docx`

## 命令清单

```bash
cd /Users/101bjb0413/Desktop/work/tmp/assignments
PY=/Users/101bjb0413/.dsh/dsh-runtimes/dsh-primary-runtime/dependencies/python/bin/python3

# 建目录
$PY _shared/new_assignment.py --id 1 --slug 教师期望与教育公平 --title "题目" --words 3000
cd 作业1_教师期望与教育公平
PIPE=../_shared/pipeline

# 1. 建池（多角度，每角度一次；作业类至少 6 个角度）
for i in 1 2 3 4 5 6 7 8; do
  $PY $PIPE/harvest.py --query "$(sed -n ${i}p queries.txt)" --per-page 15 --pages 2 \
      --from-date 2020-01-01 --out-json work/pool/c$i.json --out-bib work/pool/c$i.bib
done

# 2. 合并 + Crossref 复核（必须，年份/卷期页以 Crossref 为准）
$PY $PIPE/build_pool.py --in work/pool/c?.json --out work/pool/pool.json --bib work/pool/pool.bib
$PY $PIPE/reconcile.py --in work/pool/pool.json --out work/pool/pool_cf.json \
    --bib-out work/pool/pool_final.bib --delay 0.35

# 3. 选定子集 → 抓全文（OA 才抓；403 就标「仅摘要级」）
$PY $PIPE/fetch_text.py --in work/pool/shortlist.json --limit 40 --outdir work/texts --timeout 60

# 4. 抽逐字原句（不许改写）
$PY $PIPE/find_quotes.py --text work/texts/<key>.txt --terms "keyword1,keyword2" --max 3

# 5a. 中文文献：候选发现（尽力而为）+ 页面核验（必做）
$PY _shared/harvest_cn.py --query "主题 关键词" --out work/pool/cn_cand.json
$PY _shared/verify_cn.py --in work/pool/cn_candidates.json --out work/pool/cn_verify.json
#     产出 work/pool/cn_selected.json（lang="zh" + verify{source,url,status}）

# 5b. 生成引用串（机器填，禁止手抄；英文 + 中文混排）
$PY _shared/gbt_refs.py --in work/pool/final_ordered.json --out 作业N_参考文献.md
#     引用格式按模板时（如 小论文草地恢复）：
$PY _shared/gbt_refs.py --in work/pool/final_ordered.json --out 作业N_参考文献.md --style template
#     记录需带 title_en / venue_en / authors_en（学位论文再带 city_en / degree_en）
#    APA 7 的作业改用：$PY $PIPE/apa_refs.py --in work/pool/final_selected.json --out refs_apa.md

# 6. 验收（三条全绿才交付阶段 1）
CROSSREF_MAILTO=research@example.org $PY $PIPE/verify_all.py work/pool/final_refs.bib --json work/pool/final_verify.json
$PY $PIPE/check_quotes.py --md 作业N_02_文献清单.md --texts work/texts
#    框架 ↔ 清单 citekey 双向比对（见下）

# 7a. 自查门（2026-11 新增，必须先过）：套路句 / 翻译腔 / 年份与文献一致
$PY _shared/check_selfcheck.py --md 作业N_paper.md --json work/selfcheck.json   # exit 0 才往下走
#     细则与改写示例见 references/self-check.md

# 7b. 写完全文再过三条硬规则 + 人类文风体检（用户 2026-10 要求）
$PY _shared/check_paper_rules.py --md 作业N_paper.md --refs 12 --all-chinese --min-chars 3000 --ref-style template
$PY _shared/check_style.py --md 作业N_paper.md --json work/style_report.json
#    文风阈值与写法见 references/human-style-grassland.md（句长起伏/段长起伏/数字密度/模板词）
#    规则：全文 0 个问号；同一段内同一文献只引 1 次；参考文献 N 条且全部中文；
#          引用编号按首次出现 1..N 严格递增；正文汉字数达标

# 8. 渲染 docx
$PY _shared/render_zuoye_docx.py --md 作业N_paper.md --out 作业N_论文.docx
#     引用格式按模板时：加 --ref-style template（正文 [n] 变上标、参考文献 9pt/0.5in 悬挂、
#     标题渲染为「参考文献References：」）
```

## paper.md 约定（`render_zuoye_docx.py` 解析）

```markdown
---
title: 中文题目
title_en: English Title
---
## 摘要
【摘 要】……（200 字左右）
## 关键词
【关键词】甲；乙；丙
## Abstract
**Abstract:** ……（100 words）
## Keywords
**Keywords:** A; B; C
## 一、引言
### （一）小标题
#### 1. 小小标题
正文段落（首行缩进 2 字符、1.5 倍行距、宋体小四）
## 参考文献
[1] ……
```

## 版式（`render_zuoye_docx.py` 已实现，别改）

| 元素 | 字体 / 字号 |
|---|---|
| 中文标题 | 宋体 小二（18 pt）加粗居中 |
| 英文标题 | Times New Roman 18 pt 加粗居中 |
| 摘要 / 关键词 | 宋体 五号（10.5 pt），标签加粗 |
| Abstract / Keywords | Times New Roman 五号（10.5 pt），标签加粗 |
| 正文 | 宋体 小四（12 pt），首行缩进 2 字符 |
| 一级标题 | 宋体 小三（15 pt）加粗 |
| 二级标题 | 宋体 四号（14 pt）加粗 |
| 三级标题 | 宋体 小四（12 pt）加粗 |
| 参考文献（GB/T 7714） | 宋体 五号（10.5 pt），悬挂缩进 0.29 in |
| 参考文献（模板风格 `--ref-style template`） | 宋体 小五（9 pt）；中文条目悬挂 0.5 in + 制表位 0.5 in，**英文对照行 left 0.5 in / first 0（首字符与中文作者首字对齐）**；标题「参考文献References：」 |

### 封面（`--cover`，2026-11 起支持）

作业要求「封面参照某某大学研究生院课程论文封面格式」时，用内置封面页，不要手搓表格：

```bash
$PY _shared/render_zuoye_docx.py --md 作业N_paper.md --out 作业N_论文.docx \
    --cover --course 教育管理 --cover-date "2026年12月" \
    --name "张三" --student-id "2026xxxx" --major "教育管理" --college "公共政策与管理学院" --teacher "某某"
```

- 第 1 页：`南 昌 大 学`（宋体 36 pt 加粗）+ `研究生课程论文`（26 pt 加粗）+ 8 行字段表
  （课程名称 / 论文题目 / 姓　　名 / 学　　号 / 专　　业 / 学院（部）/ 任课教师 / 完成日期），
  字段值带下边框、留空则给全角空格占位（用户在 Word 里直接填），表后自动分页。
- 换学校/换模板时只改 `add_cover()` 的三行标题与 `rows` 字段，不要动正文版式。
- 结构断言里加：封面首行、8 字段、`tables==1`、`w:type="page"` 分页符。

| 行距 | 全文 1.5 倍 |

## 已知坑

| 坑 | 处理 |
|---|---|
| Elsevier/Wiley/SAGE 直链 403 | 标「仅摘要级」，不硬凑；正文不引用未读全文的具体结论；先查 Unpaywall 的机构库/PMC 备用链接 |
| PMC 落地页返回 HTML 拦截 | 走 Europe PMC JATS XML：`https://www.ebi.ac.uk/europepmc/webservices/rest/<PMCID>/fullTextXML`（注意：无 PDF 分页，摘录页码标章节） |
| 中文库（知网/万方）元数据不可核验 | 不是不能引：按 `references/cnki.md` 用**文章页**核验（知网空间/手机知网/万方镜像/期刊官网），状态 `verified_cn_*`；拿不到全文标「仅摘要级」 |
| 中文文献与英文文献混排后编号错乱 | 正文先用 citekey 占位（如 `[lorenz2021subtle]`），最后按首次出现顺序统一编号；参考文献表用 `gbt_refs.py` 一次生成 |
| 标题写成问句 | 用陈述句直接说目的（「……的机制、偏差与学校改进」），**不要问号** |
| 正文里夹问句 | 一律改陈述句；问号改逗号/句号；`check_paper_rules.py` 会按全文 0 问号验收 |
| 一段里反复引同一篇 | 同一段只引 1 次，跨段再引；反复引同一篇是凑数 |
| 要求「全部中文 12 篇」还掺英文 | 严格 N 条全中文；学位论文用 `[D]. 城市: 单位, 年.`，期刊用 `[J]` |
| 作业要求 `[1]` 顺序编码制 | 用 `gbt_refs.py`，不要套 APA；正文 `[n]` 首次出现顺序必须与编号一致 |
| 题名页/姓名学号 | 作业没要求就不加；用户需要时用 `--author` 传 |
| 纸张 | 中文作业用 **A4**（`render_zuoye_docx.py` 已内置，与 `论文模板.docx` 一致），不要用 python-docx 默认的 Letter |
| 用户说「doc 格式」 | 交付 `.docx`（模板本身即 .docx）。**不要**用 macOS `textutil` 转 `.doc`：实测会丢 eastAsia 宋体属性、A4 页面变成 Letter。用户确需 `.doc` 时，让其在 Word 里「另存为 Word 97-2003」 |
| 版式验收 | `render_zuoye_docx.py` 之后跑结构断言（A4/页边距/三级标题 15·14·12pt/正文首行缩进 2 字符/1.5 倍行距/悬挂缩进/引用闭环），本机无宋体只做属性断言 |

## 框架 ↔ 清单 citekey 比对

```bash
$PY - <<'EOF'
import re
fw=set(re.findall(r'`([a-z]+20\d\d[a-z0-9]*)`', open('作业N_01_框架.md',encoding='utf-8').read()))
lst=set(re.findall(r'\*\*citekey\*\*：`([^`]+)`', open('作业N_02_文献清单.md',encoding='utf-8').read()))
print("框架有、清单无:", sorted(fw-lst) or "无")
print("清单有、框架未用:", sorted(lst-fw) or "无")
EOF
```
