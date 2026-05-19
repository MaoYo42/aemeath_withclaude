#!/usr/bin/env bash
# Aemeath Claude Pet - macOS Setup Script
# 配置 Claude Code hooks + MCP 与桌宠联动

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_BUNDLE="$SCRIPT_DIR/src-tauri/target/release/bundle/macos/Aemeath Claude Pet.app"
BINARY_PATH="$APP_BUNDLE/Contents/MacOS/aemeath-claude"

if [ ! -f "$BINARY_PATH" ]; then
    echo "❌ 未找到二进制文件: $BINARY_PATH"
    echo "请先构建: cd $SCRIPT_DIR && npm install && npm run tauri build"
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
        'hooks': [{'type': 'command', 'command': \"pgrep -q 'aemeath-claude' || open '$APP_BUNDLE'\"}]
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

# === 可选：添加到登录项 ===
echo ""
echo "ℹ️  如需开机自启："
echo "  系统设置 → 通用 → 登录项 → 添加 \"Aemeath Claude Pet.app\""

echo ""
echo "🎉 配置完成！请重启 Claude Code 使配置生效。"
echo ""
echo "App Bundle: $APP_BUNDLE"
echo "手动启动: open '$APP_BUNDLE'"
