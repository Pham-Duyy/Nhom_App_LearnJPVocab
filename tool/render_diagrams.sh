#!/usr/bin/env bash
# Xuất các sơ đồ Mermaid trong docs/diagrams/*.mmd ra PNG và SVG để chèn vào
# báo cáo. Dùng Microsoft Edge chạy ẩn (không cần cài Node.js); thư viện
# Mermaid tải từ CDN, nội dung sơ đồ không gửi đi đâu.
#
# Chạy (Git Bash, từ thư mục gốc dự án): bash tool/render_diagrams.sh
set -euo pipefail

EDGE="${EDGE:-/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe}"
OUT=docs/diagrams/png
TMP=$(mktemp -d)
mkdir -p "$OUT"

for source in docs/diagrams/*.mmd; do
  name=$(basename "$source" .mmd)
  page="$TMP/$name.html"
  {
    cat <<'EOF'
<!doctype html><html><head><meta charset="utf-8">
<style>html,body{margin:0;background:#fff}#wrap{display:inline-block;padding:24px 24px 64px}svg{max-width:none!important}</style>
<script src="https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.min.js"></script></head><body><div id="wrap">
<pre class="mermaid" id="src">
EOF
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$source"
    cat <<'EOF'
</pre></div>
<script>
mermaid.initialize({startOnLoad: false, theme: 'default', fontFamily: 'Segoe UI, Arial',
  themeVariables: {fontSize: '15px'}, flowchart: {useMaxWidth: false},
  sequence: {useMaxWidth: false},
  class: {useMaxWidth: false, hideEmptyMembersBox: true}});
mermaid.run({querySelector: '#src'}).then(() => {
  // Mermaid 11 cho SVG rộng 100% khung; đặt lại đúng kích thước thật.
  const svg = document.querySelector('#wrap svg');
  const view = svg.viewBox.baseVal;
  svg.setAttribute('width', view.width);
  svg.setAttribute('height', view.height);
  svg.style.maxWidth = 'none';
  const box = document.getElementById('wrap').getBoundingClientRect();
  document.title = 'DONE ' + Math.ceil(box.width) + 'x' + Math.ceil(box.height);
}).catch((e) => { document.title = 'ERR ' + e; });
</script></body></html>
EOF
  } > "$page"

  url="file:///$(cygpath -m "$page")"
  # Lần 1: vẽ trong cửa sổ lớn để đo kích thước thật và lấy SVG.
  "$EDGE" --headless=new --disable-gpu --window-size=4000,4000 \
    --virtual-time-budget=20000 --dump-dom "$url" > "$TMP/$name.dom" 2>/dev/null
  title=$(grep -o '<title>[^<]*</title>' "$TMP/$name.dom" | sed 's/<[^>]*>//g')
  if [[ $title != DONE* ]]; then
    echo "$name: lỗi vẽ sơ đồ ($title)" >&2
    continue
  fi
  size=${title#DONE }
  sed -n 's/.*\(<svg.*<\/svg>\).*/\1/p' "$TMP/$name.dom" | head -1 > "$OUT/$name.svg"
  # Lần 2: chụp PNG đúng kích thước, độ phân giải gấp đôi cho nét khi in.
  "$EDGE" --headless=new --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=2 --window-size="${size/x/,}" \
    --virtual-time-budget=20000 \
    --screenshot="$(cygpath -w "$PWD/$OUT/$name.png")" "$url" >/dev/null 2>&1
  echo "$name: $size"
done
rm -rf "$TMP"
