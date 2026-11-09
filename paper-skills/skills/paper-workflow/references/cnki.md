# 中文知网文献：检索、核验与著录

> 适用：作业/论文明确要求「中文文献」「知网文献」「中文核心期刊」时。
> 核心原则不变：**不凭记忆写引用**。中文文献按「页面核验」而不是「DOI 能解析」来判。

## 0. 为什么中文文献要单列一套流程（实测事实）

| 事实 | 后果 |
|---|---|
| 中文教育/心理类期刊绝大多数**不在 Crossref**（心理学报、心理科学进展、华东师大教育科学版等均查不到） | 不能像英文那样用 Crossref 核验 |
| CNKI DOI 多为 `10.3969/...`、`10.16382/...`（ChinaDOI） | `doi.org` 解析会被安全盾拦截（HTTP 403 Security Challenge），不能当核验手段 |
| OpenAlex 对中文刊覆盖差，且 keyless 有每日配额 | 不能做主力检索 |
| CNKI 检索接口需要登录/签名（`kns.cnki.net`、`wap.cnki.net/gate` 均返回登录或空响应） | 脚本无法直接调 CNKI 检索 |
| 百度学术 403、Google Scholar 403、Bing 对中文查询分词异常 | 常规学术搜索不可靠 |
| 知网空间 `www.cnki.com.cn`、手机知网 `wap.cnki.net`、万方镜像 `wf.hbdlib.cn` 的**文章页**可以直接抓 | 核验可行（本文档的核心） |

## 1. 能用的一手来源（核验用）

| status | 页面类型 | URL 形态 | 能拿到的字段 |
|---|---|---|---|
| `verified_cn_journal` | 期刊官网（Magtech 平台） | `jps.ecnu.edu.cn/CN/abstract/abstract11396.shtml`、`devpsy.bnu.edu.cn`、`journal.psych.ac.cn`、`xbjk.ecnu.edu.cn` | **最全**：题名、全部作者、刊名、年、卷、期、起止页、DOI、摘要（`citation_*` meta） |
| `verified_cn_wanfang` | 万方数据镜像（简体 ASP 版） | `http://wf.hbdlib.cn/D/Periodical_<万方ID>.aspx` | 题名、作者、刊名、**年卷(期)**、DOI、摘要、关键词（无起止页） |
| `verified_cn_cnki` | 知网空间 | `http://www.cnki.com.cn/Article/CJFDTotal-<CNKI文件名>.htm` | 题名、作者、刊名、年、期、摘要、关键词（无卷/页） |
| `verified_cn_cnki` | 手机知网 | `https://wap.cnki.net/touch/web/Journal/Article/<CNKI文件名>.html` | 题名、作者、机构、刊名、年、期、摘要、关键词（无卷/页） |

判定标准：**题名 + 一作 + 年**三项与页面一致，才写 `verified_cn_*`；不一致记 `fail:*`，不许"差不多就收"。

## 2. 检索（发现线索）怎么做

脚本 `_shared/harvest_cn.py` 只是「尽力而为」：搜狗结果页偶尔会直接暴露 `cnki.com.cn/Article/...`、
`d.wanfangdata.com.cn/Periodical/...` 链接。**返回 0 条是常态，不是 bug**。更可靠的是：

1. **web_search 工具**（本项目内可用）：用中文检索词 + 年份，结果里常出现
   `wap.cnki.net/...`、`read.cnki.net/...`、`wf.hbdlib.cn/...`、`xueshu.baidu.com/...` 页面；
   从 URL 里取出 CNKI 文件名（如 `XLKX202403012`）或万方 ID（如 `lzjyxyxb202202023`）。
2. **期刊官网过刊目录**：CSSCI 期刊官网（心理科学、心理发展与教育等）有年/期目录，
   逐期 grep「期望」即可；Magtech 的卷期页形如 `volumn_<id>.shtml`。
3. **CNKI 热门词页**：`https://wiki.cnki.com.cn/HotWord/<id>.htm`（如「教师期望」=178323）
   会列出相关文献线索。
4. **代理/镜像链接**（web_search 常返回）：形如
   `https://xxx.webvpn.xxx.edu.cn/touch/web/Journal/Article/<FILE>.html`、
   `https://r.cnki.net/kcms/detail/detail.aspx?...&filename=<FILE>` —— 从中抽 `<FILE>`，
   换成 `https://wap.cnki.net/touch/web/Journal/Article/<FILE>.html` 即可核验。

**不要做**：不要用百度学术/Google Scholar 抓元数据（403）；不要用 doi.org 验证 CNKI DOI；
不要因为搜不到就凭记忆补几条中文文献。

## 3. 核验命令

```bash
PY=/Users/101bjb0413/.dsh/dsh-runtimes/dsh-primary-runtime/dependencies/python/bin/python3

# 1) 发现候选（尽力而为；常返回 0 条，按第 2 节手工补链接）
$PY _shared/harvest_cn.py --query "教师期望 学业成就" --query "教师期望 学习投入" \
    --out work/pool/cn_cand.json

# 2) 页面核验（核心步骤）：给 citekey + url + expect(标题/一作/年)
$PY _shared/verify_cn.py --in cn_candidates.json --out work/pool/cn_verify.json
#    单条调试：$PY _shared/verify_cn.py --url "<文章页URL>" --show

# 3) 核验通过的记录写进 work/pool/cn_selected.json（字段：citekey/title/authors/venue/
#    year/volume/issue/pages/doi/lang="zh"/verify{source,url,status,checked}）

# 4) 与英文记录合并，按正文首次引用顺序排列后生成 GB/T 7714
$PY ../_shared/gbt_refs.py --in work/pool/final_ordered.json --out 作业N_参考文献.md
```

`cn_candidates.json` 示例：

```json
{"records": [
  {"citekey": "chen2024xiuqie",
   "url": "https://jps.ecnu.edu.cn/CN/abstract/abstract11396.shtml",
   "expect": {"title": "羞怯对初中生学业拖延的影响：教师期望知觉与自我价值感的中介作用",
              "author": "陈英敏", "year": 2024}}
]}
```

## 4. 著录（GB/T 7714 中文格式）

`gbt_refs.py` 已支持 `lang: "zh"`：

- 作者：中文姓名原样、`，` 分隔；**超过 3 位取前 3 位 + ", 等"**
- 期刊：`作者. 题名[J]. 刊名, 年, 卷(期): 起止页. DOI: xxx.`
- 缺卷/缺页时降级：`刊名, 年(期).`（知网空间/万方页面没有起止页，**不许编**）
- 英文条目仍走原格式（作者姓氏大写 + 首字母缩写 + et al.）

## 5. 已知坑（都踩过）

| 坑 | 处理 |
|---|---|
| CNKI 检索接口 403/需登录 | 不硬调；用第 2 节的手工发现渠道 |
| `doi.org` 打开 CNKI DOI 报 Security Challenge | 不把 DOI 解析当核验；用文章页核验 |
| 万方镜像 404 | 万方 ID 大小写/前缀必须与检索结果一致；`/D/Thesis_...` 是学位论文，`/D/Periodical_...` 才是期刊 |
| 万方镜像页无起止页 | 按 `年(期)` 著录，或从期刊官网补页码 |
| 手机知网标题里含「-刊名YYYY年NN期」 | 用 `-刊名` 与 `-手机知网` 两端切分；别把刊名当题名 |
| 期刊官网有「Please wait a minute...」 | 反爬中间页；换单篇 `abstract/abstractNNNNN.shtml` 页（单篇页通常直接可读） |
| 论文里引用中文文献但没有全文 | 标「仅摘要级」，正文只写摘要能支持的结论，不编具体统计量 |
| 中文文献混排后编号错乱 | 正文用 citekey 占位，最后统一按首次出现顺序编号（见 `references/assignments.md`） |
| 知网/万方页面都拿不到页码 | GB/T 7714 允许降级为「年(期)」，但**必须**在文献清单注明「页面未给起止页」 |

## 6. 当用户要求「参考文献全部为中文、知网可查、近 5 年、N 篇」

这是 2026-10 用户明确的作业要求，按以下口径执行：

- **条数与语种**：严格 N 条（如 12 条），**不掺英文文献**；期刊 + 学位论文可以混排，
  学位论文用 `[D]. 城市: 单位, 年.`，期刊用 `[J]`。
- **年限**：全部落在「近 5 年」（当前 2026 年 → 2021–2026；以 `publication_date` 为准）。
- **「知网可查」的判据**：每篇都能在知网空间 / 手机知网 / 知网学位论文页找到文章页，
  且题名 + 一作 + 刊名（学位单位）+ 年期一致（`verified_cn_*`）。
- **发现渠道**（按实测成功率排序）：
  1. `wiki.cnki.com.cn/HotWord/<id>.htm`（如「教师期望」=178323）：页面列出相关文献的
     知网文件名（`CJFDTOTAL-XXXX.htm`），从中筛 2021+，再逐篇抓知网页面核验；
  2. 期刊官网 Magtech 检索：`POST /CN/article/advancedSearchResult.do`，
     `searchSQL=((教师期望[Title]) AND 1[Journal])`（心理科学、心理发展与教育、
     华东师大学报、心理学报、心理科学进展可用）；
  3. web_search 工具：中文检索词 + 年份，结果里的 `wap.cnki.net/.../Article/<FILE>.html`、
     `read.cnki.net/...`、`wf.hbdlib.cn/D/Periodical_*.aspx` 都可用于发现与核验；
  4. 万方镜像页：已知万方 ID 时直接拼 `http://wf.hbdlib.cn/D/Periodical_<ID>.aspx`。
- **质量取舍**：优先 CSSCI / 核心（心理科学、心理发展与教育、华东师大学报等）；
  数量不够时可用普通学报与学位论文补足，但要在清单里如实标注刊物层级，
  不把普刊说成核心。
- **别做**：不要拿「教育期望」「家长期望」「自我期望」的文献冒充「教师期望」；
  不要为了凑数把同一篇拆成两条；不要编卷期页。

## 6.5 实战：只用期刊官网（作业2 走通的路子，2026-11）

知网检索接口在本机实测全部不可用（`search.cnki.com.cn` 是 JS 壳、旧 `Search.aspx` 404、
`kns.cnki.net` 需签名），所以作业2 改用**「Magtech 期刊官网检索 + 文章页元数据」**，
全程不依赖知网也能拿到可核验的中文文献：

1. **发现**：`POST <host>/CN/article/advancedSearchResult.do`，body `searchSQL=((<词>[Abstract]) AND 1[Journal])`；
   结果页里标题链接形如 `<a href="..." class="txt_biaoti">题名</a>`（旧版模板是 `div.j-title-1`）。
   可用 host：`devpsy.bnu.edu.cn`（心理发展与教育）、`jps.ecnu.edu.cn`（心理科学）、
   `xbjk.ecnu.edu.cn`（华东师大学报教育科学版）、`journal.psych.ac.cn/xlkxjz`（心理科学进展）、
   `journal.psych.ac.cn/xlxb`（心理学报）。脚本见 `作业2_教育管理/work/magtech_discover.py`（并发、自动去重）。
2. **核验**：文章页有 `citation_title` / `citation_authors` / `citation_journal_title` /
   `citation_date` / `citation_volume` / `citation_issue` / `citation_firstpage|lastpage` / `citation_doi`。
   ⚠️ 新版页面把 `citation_title` 写成 `<meta name="citation_title" xml:lang="cn" content="...">`，
   作者是逗号分隔的 `citation_authors`（复数）——`_shared/verify_cn.py` 已于 2026-11 兼容（`meta()` 允许中间属性、
   `parse_magtech()` 回退 `citation_authors`/`citation_date`/`DC.Title`）。
3. **全文**：
   - **别直接信 PDF**：心理发展与教育等刊的 PDF 用自定义字体，`pdftotext` 抽出来是乱码；
   - 文章页 `lsdy1('RICH_HTML','<id>','<host>','<年>','article/<年>/<ISSN>/<YYMMNN>.htm')` 里的路径
     去掉 `/CN/` 前缀即可抓 HTML 全文（`<host>/article/...`），转纯文本干净可摘录；
   - 心理科学（jps）只有 PDF，`pdftotext` **默认模式**（不加 `-layout`）按栏顺序输出，句子完整；
     `-layout` 会把双栏逐行交错，摘录难以逐字命中。
4. **状态命名**：期刊官网页面记 `verified_cn_journal`（skill 认可的一手来源），
   与 `verified_cn_cnki` / `verified_cn_wanfang` 并列，不要求一定来自知网。


## 7. 与三条硬规则的关系（2026-10）

- 全文 **0 个问号**：标题/摘要/正文/结论都要过 `check_paper_rules.py`；问句改陈述句。
- **同一段内同一文献只引一次**：跨段可重复；一段内连引三次同一篇会被判失败。
- 参考文献 **N 条全中文**：`check_paper_rules.py --refs N --all-chinese`。
