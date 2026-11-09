# 引用格式模板：小论文草地恢复_终版_230903

> 用户 2026-10 指定：**作业1 的引用格式改为《小论文草地恢复_终版_230903.docx》的格式**，并固化到本 skill。
> 源文件：项目根目录 `小论文草地恢复_终版_230903.docx`（中文期刊论文，195 段、31 条参考文献）。

## 1. 正文引用（in-text）

- **数字顺序编码 + 上标**：正文中写作 `[1]`、`[1-2]`、`[8-11]`，**整个方括号连同数字为上标**（Word：`w:vertAlign=superscript`）。
- 方括号是 ASCII `[ ]`，连续编号用**半字线**连接（`[3-4]`），不写成 `[3,4]`。
- 紧贴前文、放在标点之前：`……意义重大[1-2]。`
- 只在正文出现；摘要、关键词、标题不引注。

## 2. 参考文献表（reference list）

**标题**：`参考文献References：`（中英文连写、冒号结尾；宋体、加粗、左对齐，正文五号即 10.5pt）。

**每条中文文献的格式**（编号 + 制表符）：
```
[n]<TAB>作者1, 作者2, 作者3. 题名. 刊名, 年, 卷(期): 起止页.
```
- **不带 `[J]` / `[D]` 等文献类型标识**。
- **不带 DOI**。
- 作者：**全部列出**（不用「等」/「et al.」），`姓, 名` 形式，ASCII 逗号 + 空格分隔。
- 卷期：年, 卷(期)，期号补零（`2022, 46(04): 461-72`）。
- 学位论文：`作者. 题名. 城市: 学校硕士学位论文, 年.`
- 没有卷/页码时降级为 `刊名, 年(期).`，不编造。

**对齐规则（用户 2026-10 追加）**：英文对照行的**首字符必须与中文条目的作者首字对齐**。
中文条目 = `[n]` 从 0 起 + 制表位 0.5in → 作者首字落在 **0.5in**；因此英文对照行要设
`left_indent=0.5in, first_line_indent=0`（**不要**再用悬挂缩进，否则英文会顶到 0 处）。

**英文对照行**（每条中文文献后**另起一段**、无编号、左缩进 0.5in、首行不缩进）：
```
<TAB>SURNAME I, SURNAME I, SURNAME I. English Title. English Journal, Year, Vol(Issue): pages.
```
- 作者：**姓氏全大写 + 名首字母**（如 `ZHANG J, MA L`），逗号分隔。
- 期刊名用官方英文名（CNKI 英文页 `en.cnki.com.cn/Article_en/CJFDTOTAL-<FILE>.htm` 的标题里可取到）。
- 学位论文英文行：`AUTHOR. Title. Master Thesis. City: University, Year.`
- 原文即英文的文献只写英文一条，不重复中文行。

**版式**（实测源文件）：
| 元素 | 值 |
|---|---|
| 参考文献标题 | 宋体 10.5pt 加粗、左对齐 |
| 条目 | 宋体 **9pt（小五）**、两端对齐 |
| 中文条目缩进 | 悬挂 **0.5 in**（left 0.5 / first −0.5）+ **显式制表位 0.5 in**（保证作者首字在 0.5in） |
| 英文对照行缩进 | **left 0.5 in / first 0**（首字符与中文作者首字对齐） |
| 行距 | 源文件为单倍；本项目作业要求「全文 1.5 倍行距」，**保留 1.5** |

## 3. 本项目里的对应命令

```bash
PY=/Users/101bjb0413/.dsh/dsh-runtimes/dsh-primary-runtime/dependencies/python/bin/python3
cd /Users/101bjb0413/Desktop/work/tmp/assignments

# 1) 生成模板风格参考文献（中文条目 + 英文对照行，机器生成，禁止手抄）
$PY _shared/gbt_refs.py --in work/pool/final_ordered.json --out 作业N_参考文献.md --style template
#    记录需带英文对照字段：title_en / venue_en / authors_en
#    （学位论文另带 city_en / degree_en；英文元数据取 CNKI 英文页，无官方译名时如实英译）

# 2) 渲染 docx：正文引用自动上标 + 模板风格参考文献
$PY _shared/render_zuoye_docx.py --md 作业N_paper.md --out 作业N_论文.docx --ref-style template

# 3) 检查
$PY _shared/check_paper_rules.py --md 作业N_paper.md --refs 12 --all-chinese --min-chars 3000 --ref-style template
$PY work/check_paper_docx.py        # docx 层：上标引用 / 9pt / 0.5in 悬挂 / 无 [J][D] / 英文对照 12 行
```

## 4. 换模板时怎么识别（可复用）

拿到一个新的「引用格式模板」docx，按下面顺序拆：

1. **正文引用**：找含数字/作者名的 run，看 `r.font.superscript` 或 `w:vertAlign`；
   括号是 ASCII 还是全角；范围写法（`[1-2]` / `[1,2]` / `[1–2]`）。
2. **参考文献标题**：段落文本 + 对齐 + 字号 + 是否加粗。
3. **条目结构**：编号后是空格、制表符还是句点；有无 `[J]/[D]/[M]`；
   作者分隔符；标题与刊名之间用 `.` 还是 `//`；卷期页写法；有无 DOI。
4. **是否双语**：中文条目后是否紧跟一段英文（无编号、缩进）；
   英文作者格式（`ZHANG J` vs `Zhang J.`）；学位论文英文写法。
5. **版式**：字号、悬挂缩进、行距、对齐（用 python-docx 读 `paragraph_format`）。
6. 把结论写进本文件 → 改 `gbt_refs.py --style` / `render_zuoye_docx.py --ref-style` / 检查脚本。

## 5. 已知坑

| 坑 | 处理 |
|---|---|
| 正文引用是上标，但 markdown 不表达上标 | md 里仍写 `[n]`；由 `render_zuoye_docx.py --ref-style template` 渲染成上标 run |
| 参考文献没有 `[J]/[D]`，机器核验脚本按 `[J]` 找会漏 | 模板风格下「中文文献」判定改为「含汉字」，见 `check_paper_rules.py --ref-style template` |
| 英文对照需要官方译名 | 优先 CNKI 英文页（`en.cnki.com.cn/Article_en/CJFDTOTAL-<FILE>.htm`）；无官方页时如实英译并在数据文件里标注 `source` |
| 期刊英文名拼写错误（如 `EducationEquity`） | 采用时人工修正为 `Education Equity`，并保留来源说明 |
| 学位论文英文页不存在 | 用「Master Thesis. City: University, Year.」按中文信息英译 |
| 模板参考文献 9pt 与本项目「宋体五号」旧习惯冲突 | 作业未规定参考文献字号时以模板为准；若作业明确要求五号，改 `--ref-style gbt` 或显式覆盖 |
| 英文对照行沿用悬挂缩进，首字符顶到最左（0 处），与中文作者不齐 | 英文行改 `left=0.5in, first=0`；中文行加显式制表位 0.5in；`check_paper_docx.py` 已加断言 |
| 只靠默认制表位，`[n]` 变宽时作者会跳到 1.0in | 中文条目显式 `tab_stops.add_tab_stop(Inches(0.5))` |
