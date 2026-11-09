#!/bin/sh
# 安装本包里的 skills 到 Agent 的 skills 目录。
#
#   ./install.sh                      # 默认装到 ~/.dsh/skills（DeepSeek Harness）
#   ./install.sh ~/.claude/skills     # Claude Code
#   ./install.sh /path/to/any/skills  # 其他 Agent
#
# 已经存在的同名技能会被跳过，不会覆盖；想覆盖就先把旧目录挪走。

set -eu

TARGET="${1:-$HOME/.dsh/skills}"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)/skills"

if [ ! -d "$SRC_DIR" ]; then
  echo "找不到 $SRC_DIR，请在解压后的包根目录运行本脚本。" >&2
  exit 1
fi

mkdir -p "$TARGET"
installed=0
skipped=0

for skill in "$SRC_DIR"/*; do
  [ -d "$skill" ] || continue
  name="$(basename "$skill")"
  if [ -e "$TARGET/$name" ]; then
    echo "跳过（已存在）：$name"
    skipped=$((skipped + 1))
  else
    cp -R "$skill" "$TARGET/$name"
    installed=$((installed + 1))
  fi
done

echo ""
echo "完成：新装 $installed 个，跳过 $skipped 个 → $TARGET"
echo "验证：ls \"$TARGET\" | head"
