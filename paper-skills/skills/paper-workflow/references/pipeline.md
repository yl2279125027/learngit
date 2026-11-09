# 流水线命令手册

所有命令在 `/Users/101bjb0413/Desktop/work/tmp/papers/<论文目录>/` 下执行。
`$PIPE=../_shared/pipeline`，`$PY=/Users/101bjb0413/.dsh/dsh-runtimes/dsh-primary-runtime/dependencies/python/bin/python3`

## 0. 准备

```bash
$PY $PIPE/new_paper.py --id 02 --slug 你的短名 --title "论文题目"
cd 02_你的短名
```

## 1. 多角度建池（必须多轮，单轮会漏）

每个角度一次，per-page 10：

```bash
for q in "核心概念1 关键词" "核心概念2 机制" "元分析 publication bias" "教师 情境" "中国学生 样本"; do
  $PY $PIPE/harvest.py --query "$q" --per-page 10 --from-date 2005-01-01 \
      --out-json work/pool/c$i.json --out-bib work/pool/c$i.bib
done
$PY $PIPE/build_pool.py --in work/pool/c1.json ... work/pool/c5.json \
    --out work/pool/pool.json --bib work/pool/pool.bib
```

输出要检查 `OpenAlex 报告总数` 与 `实际取回`，实取不足时脚本会警告 —— 不要当穷尽检索。

## 2. Crossref 复核（关键，别跳）

```bash
$PY $PIPE/reconcile.py --in work/pool/pool.json --out work/pool/pool_cf.json \
    --bib work/pool/pool_final.bib --delay 0.4
```

它修正：online-first 年份、缺失副标题、缺失卷期页；标记 429/无 DOI/一作不符。
实测：58 条里 10 条年份与正式版不同（17%），不修正会写错参考文献年份。

## 3. 引用核验

```bash
CROSSREF_MAILTO=you@example.org $PY $PIPE/verify_all.py work/pool/pool_final.bib --json work/pool/verify.json
```

**退出码必须为 0**。`verified_subtitle` 是本项目的正常状态（上游脚本漏比 subtitle）。

## 4. 选定子集

写一个 16–20 条的名单 JSON（参考 `01_growth-mindset/work/pool/final_selected.json`），
筛选原则：正方 ≥3、反方 ≥2、机制 ≥2、边界条件 ≥2、本土/跨文化 ≥1；优先 OA 可得全文的。

## 5. 抓全文 → 抽原句

```bash
$PY $PIPE/fetch_text.py --in work/pool/selected.json --limit 20 --outdir work/texts --timeout 75
$PY $PIPE/find_quotes.py --text work/texts/<key>.txt --terms "关键词1,关键词2" --max 3
```

## 6. 生成交付物

```bash
# 清单用模板 + 占位符，引用串由机器填（禁止手抄）
$PY $PIPE/render_list.py --template 02_文献清单.tpl.md \
    --json work/pool/final_selected.json --out 02_文献清单.md
$PY $PIPE/apa_refs.py --in work/pool/final_selected.json --out refs_apa.md
```

## 7. 交付前验收（三条全绿才交付）

```bash
CROSSREF_MAILTO=you@example.org $PY $PIPE/verify_all.py work/pool/final_refs.bib --json work/pool/final_verify.json
$PY $PIPE/check_quotes.py --md 02_文献清单.md --texts work/texts
# 框架与清单 citekey 双向比对（见 deliverables.md 的脚本片段）
```

## 8. 用户确认后：全文 → docx

```bash
$PY $PIPE/render_docx.py --md paper.md --out paper.docx \
    --author "姓名" --affiliation "学校院系" --course "课程" --instructor "教师" --date "2026年10月"
```

## 已知坑（都是踩过的，别重踩）

| 坑 | 现象 | 处理 |
|---|---|---|
| 上游核验脚本不比对 `subtitle` | 带副标题的论文被判 mismatch | 用 `verify_all.py`，不要直接用 `verify_citations.py` |
| OpenAlex 年份 = online-first | 参考文献年份错 | `reconcile.py` 取 Crossref `issued`/`published-print` |
| OpenAlex 拆错中文姓名 | 一作姓氏出现 "Jianping" | `reconcile.py` 用 Crossref 作者字段覆盖 |
| `pdftotext -layout` 双栏串行 | 抽出的"原句"是两栏交错 | 用默认阅读顺序模式；`-layout` 仅供人工核对 |
| 空白归一化吃掉 `\f` | 页码全报 p.1 | `check_quotes.py` 用哨兵保留换页符 |
| 按 citekey 分块会吃到下一节标题 | 上一节摘录被误跳过 | 同时按 `##` 切块 |
| MDPI 单页文章号 | 被拼成 `5196-5196` | `harvest.py` 已修：首末页相同只留一页 |
| Wiley/Elsevier/SAGE 直链 | HTTP 403 | 标「仅摘要级」，不硬凑；PMC 文章走 Europe PMC JATS XML |
| PsyArXiv 链接 | 返回 OSF 中间页 | 换成 `https://osf.io/download/<id>/` |
| HTML 落地页 | 拿不到 PDF | `fetch_text.py` 会追 `citation_pdf_url` / `.pdf` 链接 |
| Crossref 429 | 部分条目未复核 | `reconcile.py` 已内置退避重试 |
| 本机无宋体/黑体 | LibreOffice 报 missingFonts | 只做结构断言，视觉以用户机器 Word 为准 |
| 系统 `python3` 缺 docx | `ModuleNotFoundError` | 一律用 `$PY` |
