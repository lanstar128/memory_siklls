#!/usr/bin/env python3
"""
时间戳注入脚本
将 AI 提取的时间戳元数据注入到导出的 Markdown 对话文件中。

用法:
    python3 inject_timestamps.py --source <源文件> --metadata <JSON文件> --output <输出目录>
"""

import argparse
import json
import os
import re
import shutil
from datetime import datetime
from pathlib import Path


def load_metadata(metadata_path: str) -> dict:
    """加载时间戳元数据 JSON"""
    with open(metadata_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def inject_timestamps(content: str, turns: list) -> str:
    """
    在 Markdown 内容中注入时间戳
    将 '### User Input' 替换为 '### User Input [时间戳]'
    """
    lines = content.split('\n')
    result = []
    turn_index = 0
    
    for line in lines:
        if line.strip() == '### User Input' and turn_index < len(turns):
            time_str = turns[turn_index].get('time', '')
            result.append(f'### User Input [{time_str}]')
            turn_index += 1
        else:
            result.append(line)
    
    return '\n'.join(result)


def sanitize_filename(title: str) -> str:
    """清理文件名，移除非法字符"""
    # 移除或替换非法字符
    sanitized = re.sub(r'[<>:"/\\|?*]', '-', title)
    # 限制长度
    return sanitized[:100]


def main():
    parser = argparse.ArgumentParser(description='注入时间戳到对话 Markdown 文件')
    parser.add_argument('--source', required=True, help='源 Markdown 文件路径')
    parser.add_argument('--metadata', required=True, help='时间戳元数据 JSON 文件路径')
    parser.add_argument('--output', required=True, help='输出目录路径')
    args = parser.parse_args()
    
    # 加载元数据
    metadata = load_metadata(args.metadata)
    turns = metadata.get('turns', [])
    title = metadata.get('conversation_title', 'Untitled')
    archive_time = metadata.get('archive_time', datetime.now().strftime('%Y-%m-%d %H:%M'))
    
    # 读取源文件
    with open(args.source, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 注入时间戳
    modified_content = inject_timestamps(content, turns)
    
    # 在文件开头添加归档信息
    header = f"""---
archived: {archive_time}
turns: {len(turns)}
---

"""
    final_content = header + modified_content
    
    # 创建输出目录（按月份分组）
    date_prefix = archive_time.split(' ')[0]  # 2026-01-18
    month_dir = date_prefix[:7]  # 2026-01
    output_dir = Path(args.output) / month_dir
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # 生成输出文件名
    safe_title = sanitize_filename(title)
    output_filename = f"{date_prefix}_{safe_title}.md"
    output_path = output_dir / output_filename
    
    # 写入文件
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(final_content)
    
    print(f"✅ 已归档: {output_path}")
    print(f"   对话轮数: {len(turns)}")
    
    # 输出路径供后续脚本使用
    return str(output_path)


if __name__ == '__main__':
    main()
