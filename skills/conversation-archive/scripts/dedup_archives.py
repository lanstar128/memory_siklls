#!/usr/bin/env python3
"""
对话归档去重合并脚本
- 检测同一天内的重复归档（通过对比前2轮用户输入）
- 合并时间戳（保留所有已注入的时间戳）
- 保留轮数更多的新文件，删除旧文件
"""

import re
import os
import sys
import argparse
from pathlib import Path
from typing import List, Tuple, Optional, Dict


def extract_user_inputs(file_path: Path) -> List[Tuple[str, Optional[str]]]:
    """
    提取所有用户输入块
    返回: [(纯文本内容, 时间戳或None), ...]
    """
    content = file_path.read_text(encoding='utf-8')
    
    # 匹配 ### User Input 或 ### User Input [时间戳]
    pattern = r'### User Input(?: \[([^\]]+)\])?\n\n(.*?)(?=\n### |\n---|\Z)'
    matches = re.findall(pattern, content, re.DOTALL)
    
    result = []
    for timestamp, text in matches:
        # 清理文本：移除首尾空白，取前100字符用于对比
        clean_text = text.strip()
        result.append((clean_text, timestamp if timestamp else None))
    
    return result


def normalize_text(text: str) -> str:
    """标准化文本用于对比（移除空白差异）"""
    return re.sub(r'\s+', ' ', text.strip())[:100]


def compare_first_n_turns(file1: Path, file2: Path, n: int = 2) -> bool:
    """
    比较两个文件的前 n 轮用户输入是否一致
    返回: True 表示一致（可能是同一对话）
    """
    inputs1 = extract_user_inputs(file1)
    inputs2 = extract_user_inputs(file2)
    
    if len(inputs1) < n or len(inputs2) < n:
        return False
    
    for i in range(n):
        text1 = normalize_text(inputs1[i][0])
        text2 = normalize_text(inputs2[i][0])
        if text1 != text2:
            return False
    
    return True


def merge_timestamps(old_file: Path, new_file: Path) -> str:
    """
    将旧文件的时间戳合并到新文件
    返回: 合并后的内容
    """
    old_inputs = extract_user_inputs(old_file)
    new_content = new_file.read_text(encoding='utf-8')
    
    # 建立旧文件的时间戳索引：{规范化文本: 时间戳}
    timestamp_map: Dict[str, str] = {}
    for text, ts in old_inputs:
        if ts:
            key = normalize_text(text)
            timestamp_map[key] = ts
    
    # 在新文件中查找没有时间戳的用户输入，尝试补充
    def replace_user_input(match):
        existing_ts = match.group(1)
        text_after = match.group(2)
        
        # 如果已有时间戳，保留
        if existing_ts:
            return match.group(0)
        
        # 尝试从旧文件获取时间戳
        key = normalize_text(text_after)
        if key in timestamp_map:
            return f'### User Input [{timestamp_map[key]}]\n\n{text_after}'
        
        return match.group(0)
    
    pattern = r'### User Input(?: \[([^\]]+)\])?\n\n(.*?)(?=\n### |\n---|\Z)'
    merged = re.sub(pattern, replace_user_input, new_content, flags=re.DOTALL)
    
    return merged


def find_duplicates(dir_path: Path) -> List[Tuple[Path, Path]]:
    """
    在目录中查找重复的归档文件
    返回: [(旧文件, 新文件), ...]
    """
    md_files = sorted(dir_path.glob('*.md'))
    duplicates = []
    processed = set()
    
    for i, file1 in enumerate(md_files):
        if file1 in processed:
            continue
        
        for file2 in md_files[i+1:]:
            if file2 in processed:
                continue
            
            if compare_first_n_turns(file1, file2, n=2):
                # 确定哪个是新文件（轮数更多）
                inputs1 = extract_user_inputs(file1)
                inputs2 = extract_user_inputs(file2)
                
                if len(inputs1) <= len(inputs2):
                    old, new = file1, file2
                else:
                    old, new = file2, file1
                
                duplicates.append((old, new))
                processed.add(old)
                processed.add(new)
                break
    
    return duplicates


def dedup_directory(dir_path: Path, dry_run: bool = False) -> int:
    """
    对目录进行去重
    返回: 合并的文件对数
    """
    duplicates = find_duplicates(dir_path)
    
    if not duplicates:
        print("未发现重复文件")
        return 0
    
    for old_file, new_file in duplicates:
        old_inputs = extract_user_inputs(old_file)
        new_inputs = extract_user_inputs(new_file)
        old_ts_count = sum(1 for _, ts in old_inputs if ts)
        new_ts_count = sum(1 for _, ts in new_inputs if ts)
        
        print(f"\n发现重复:")
        print(f"  旧文件: {old_file.name} ({len(old_inputs)} 轮, {old_ts_count} 个时间戳)")
        print(f"  新文件: {new_file.name} ({len(new_inputs)} 轮, {new_ts_count} 个时间戳)")
        
        if dry_run:
            print(f"  [DRY-RUN] 将合并时间戳并删除旧文件")
        else:
            # 合并时间戳
            merged_content = merge_timestamps(old_file, new_file)
            new_file.write_text(merged_content, encoding='utf-8')
            
            # 删除旧文件
            old_file.unlink()
            print(f"  ✅ 已合并时间戳并删除旧文件")
    
    return len(duplicates)


def main():
    parser = argparse.ArgumentParser(description='对话归档去重合并')
    parser.add_argument('--dir', required=True, help='归档目录路径')
    parser.add_argument('--dry-run', action='store_true', help='仅显示将执行的操作，不实际修改')
    
    args = parser.parse_args()
    dir_path = Path(args.dir).expanduser()
    
    if not dir_path.exists():
        print(f"错误: 目录不存在 {dir_path}")
        sys.exit(1)
    
    count = dedup_directory(dir_path, dry_run=args.dry_run)
    print(f"\n处理完成: 合并了 {count} 对重复文件")


if __name__ == '__main__':
    main()
