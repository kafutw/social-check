#!/bin/zsh
# 社群發文核對表：加密後推上 GitHub Pages（kafutw/social-check）。
# 密碼：環境變數 SC_PASSWORD，或 ~/.config/kafu/socialcheck_pw（600，不進 repo、不進記憶）
set -e
cd "${0:A:h}"
REPO=kafutw/social-check
export PATH="$HOME/.local/node/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
[ -n "$SC_PASSWORD" ] || SC_PASSWORD="$(cat ~/.config/kafu/socialcheck_pw 2>/dev/null)"
[ -n "$SC_PASSWORD" ] || { echo "沒有密碼，沒推"; exit 2; }
export SC_PASSWORD
/usr/bin/python3 ~/bin/kafu_socialcheck.py html --stdout > src/app.html
node build.mjs
[ -d .git ] || git init -q -b main
printf 'src/\n*.log\n.DS_Store\n' > .gitignore
git add index.html .gitignore build.mjs publish.sh favicon.png apple-touch-icon.png
git commit -qm "更新社群發文核對表 $(date '+%m/%d %H:%M')" || { echo "內容沒有變動"; exit 0; }
if ! git remote get-url origin >/dev/null 2>&1; then
  gh repo create "$REPO" --public --source=. --remote=origin --push
  gh api -X POST "repos/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null && echo "已開啟 GitHub Pages"
else
  git push -q origin main
fi
echo "網址：https://kafutw.github.io/social-check/"
