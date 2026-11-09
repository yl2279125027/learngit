# 交付物规范与验收

## A. 01_框架.md

必须包含：元信息、**默认假设表**（用户没明说时的取值 + 改动成本）、字数分配表、逐节骨架（每节"要回答什么 + 论点 + 证据"）、**证据映射表**（章节 / 论点 / citekey / 证据类型 / 核验 / 可得性）。

判断标准：用户只看这一页，就能决定"这个方向对不对、字数够不够、证据撑不撑得住"。

## B. 02_文献清单.md

每条固定字段：`citekey` → 核验状态 → APA 7 引用 → 角色（用于第几节、承担什么论证）→ 概述（3–5 句，写样本/方法/关键结果）→ 逐字原文摘录（带页码）→ 原文可得性。

**禁止**："具有重要的理论与实践意义"这类空话；禁止把摘要改写成"原文摘录"。

引用串必须由 `render_list.py` 填入，禁止手抄 —— 手抄是年份/卷期页错误的主要来源。

## C. refs_apa.md

`apa_refs.py` 生成：字母序、20 作者以内全列、21+ 用省略号、DOI 作 URL 且末尾不加句号、期号用 en dash、刊名与卷号斜体。

生成后若脚本报「疑似 Title Case」，**必须人工确认**：APA 要求文章题名句首大写，但专有名词（理论名、地名）要保留大写，机器无法判断。

## 验收命令（三条全绿才交付阶段 1）

```bash
PIPE=../_shared/pipeline
PY=/Users/101bjb0413/.dsh/dsh-runtimes/dsh-primary-runtime/dependencies/python/bin/python3

# 1. 引用核验：退出码 0
CROSSREF_MAILTO=you@example.org $PY $PIPE/verify_all.py work/pool/final_refs.bib --json work/pool/final_verify.json

# 2. 摘录逐字校验：退出码 0
$PY $PIPE/check_quotes.py --md 02_文献清单.md --texts work/texts

# 3. 框架 ↔ 清单 citekey 双向比对：无差集
$PY - <<'EOF'
import re
fw=set(re.findall(r'`([a-z]+20\d\d[a-z0-9]*)`', open('01_框架.md',encoding='utf-8').read()))
lst=set(re.findall(r'\*\*citekey\*\*：`([^`]+)`', open('02_文献清单.md',encoding='utf-8').read()))
print("框架有、清单无:", sorted(fw-lst) or "无")
print("清单有、框架未用:", sorted(lst-fw) or "无")
EOF
```

## D. 阶段 2 的 paper.md 约定（供 render_docx.py 解析）

| Markdown | docx 效果 |
|---|---|
| `# 题目` | 标题页（加粗居中），不进正文 |
| `## 摘要` / `## 1 引言` / `## References` | 一级标题：居中加粗；`References` 之后按参考文献排版 |
| `### 2.1 xxx` | 二级标题：左对齐加粗 |
| `#### 2.1.1 xxx` | 三级标题：左对齐加粗斜体 |
| 普通段落 | 双倍行距、首行缩进 0.5in |
| `- 条目`（在 References 下） | 悬挂缩进 0.5in |
| `**粗体**` / `*斜体*` | 行内加粗 / 斜体 |

排版验收：`check_office.py` verdict=pass，且 14 项版式断言通过（脚本片段见 `papers/01_growth-mindset/README.md` 的历史记录）。
