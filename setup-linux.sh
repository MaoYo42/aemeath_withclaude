#!/usr/bin/env bash
# Aemeath Claude Pet - Linux Setup Script
# 配置 Claude Code hooks + MCP 与桌宠联动

set -e

BINARY_PATH="$(cd "$(dirname "$0")" && pwd)/src-tauri/target/release/aemeath-claude"
HOOKS_SOURCE="$(cd "$(dirname "$0")" && pwd)/docs/hooks.linux.json"

if [ ! -f "$BINARY_PATH" ]; then
    echo "❌ 未找到二进制文件: $BINARY_PATH"
    echo "请先执行: cd $(dirname "$0") && npm install && cargo build --manifest-path src-tauri/Cargo.toml --release"
    exit 1
fi

# === 合并 hooks 到 settings.json ===
SETTINGS="$HOME/.claude/settings.json"
if [ ! -f "$SETTINGS" ]; then
    mkdir -p "$HOME/.claude"
    echo '{}' > "$SETTINGS"
fi

echo "📝 配置 Claude Code hooks..."

python3 -c "
import json

with open('$SETTINGS', 'r') as f:
    settings = json.load(f)

hooks = {
    'SessionStart': [{
        'matcher': '',
        'hooks': [{'type': 'command', 'command': \"if ! pgrep -x 'aemeath-claude' > /dev/null; then (nohup $BINARY_PATH &>/dev/null &); fi\"}]
    }],
    'UserPromptSubmit': [{
        'matcher': '',
        'hooks': [{'type': 'http', 'url': 'http://127.0.0.1:9527/api/hook/thinking'}]
    }],
    'PreToolUse': [{
        'matcher': '',
        'hooks': [{'type': 'http', 'url': 'http://127.0.0.1:9527/api/hook/working'}]
    }],
    'PostToolUse': [{
        'matcher': '',
        'hooks': [{'type': 'http', 'url': 'http://127.0.0.1:9527/api/hook/done'}]
    }],
    'Stop': [{
        'matcher': '',
        'hooks': [{'type': 'http', 'url': 'http://127.0.0.1:9527/api/hook/idle'}]
    }],
    'PermissionRequest': [{
        'matcher': '',
        'hooks': [{'type': 'http', 'url': 'http://127.0.0.1:9527/api/hook/permission'}]
    }]
}

settings['hooks'] = hooks

with open('$SETTINGS', 'w') as f:
    json.dump(settings, f, indent=2)

print('✅ hooks 已写入 settings.json')
"

# === 配置 MCP ===
MCP_CONFIG="$HOME/.claude/.mcp.json"
MCP_DATA='{
  "aemeath": {
    "type": "http",
    "url": "http://127.0.0.1:9528/mcp"
  }
}'

echo "$MCP_DATA" > "$MCP_CONFIG"
echo "✅ .mcp.json 已创建"

echo ""
echo "🎉 配置完成！请重启 Claude Code 使配置生效。"
echo ""
echo "桌宠二进制路径: $BINARY_PATH"
echo "手动启动: $BINARY_PATH &"
