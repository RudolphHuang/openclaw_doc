#!/bin/bash

# OpenClaw 模型批量测试脚本
# 测试所有已配置的模型

# 定义模型列表
models=(
    "claude-sonnet-4.5"
    "gpt-5-mini"
    "gpt-5-nano"
    "gpt-5.2"
    "claude-opus-4.6"
    "claude-sonnet-4.6"
    "claude-haiku-4.5"
    "claude-opus-4.5"
    "gemini-3.1-pro"
    "gemini-3-flash"
)

# 测试消息
message="你好"

# 遍历测试每个模型
echo "=========================================="
echo "开始批量测试 OpenClaw 模型"
echo "测试消息: \"$message\""
echo "=========================================="
echo ""

for model in "${models[@]}"; do
    echo "------------------------------------------"
    echo "测试模型: $model"
    echo "------------------------------------------"
    
    openclaw agent --agent "$model" --message "$message"
    
    echo ""
    echo "✓ 模型 $model 测试完成"
    echo ""
done

echo "=========================================="
echo "所有模型测试完成！"
echo "=========================================="
