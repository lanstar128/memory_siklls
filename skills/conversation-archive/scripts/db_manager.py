#!/usr/bin/env python3
"""
对话索引数据库管理脚本
使用 SQLite 管理对话记录索引，支持全文搜索。

用法:
    # 添加记录
    python3 db_manager.py --action add --metadata <JSON> --file <归档路径>
    
    # 搜索
    python3 db_manager.py --action search --keyword "关键词"
    
    # 按日期范围搜索
    python3 db_manager.py --action search --date-range "2026-01-01,2026-01-31"
    
    # 列出所有记录
    python3 db_manager.py --action list
"""

import argparse
import json
import os
import sqlite3
from datetime import datetime
from pathlib import Path
from typing import Optional


def get_data_dir(cli_data_dir: Optional[str] = None) -> Path:
    """Resolve AMS data dir with CLI > env > default precedence."""
    if cli_data_dir:
        return Path(cli_data_dir).expanduser()

    data_dir = os.environ.get('AI_MEMORY_DATA_DIR') or os.environ.get('AMS_DATA_DIR')
    if data_dir:
        return Path(data_dir).expanduser()

    memory_root = os.environ.get('AI_MEMORY_ROOT') or os.environ.get('AMS_MEMORY_ROOT')
    if memory_root:
        return Path(memory_root).expanduser() / 'data'

    return Path.home() / '.ai-memory' / 'data'


def get_db_path(data_dir: Path) -> Path:
    return data_dir / 'conversations.db'


def init_db(db_path: Path):
    """初始化数据库，创建表结构"""
    db_path.parent.mkdir(parents=True, exist_ok=True)
    
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # 主表
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS conversations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            project_path TEXT,
            file_path TEXT NOT NULL,
            archive_time TEXT NOT NULL,
            turn_count INTEGER,
            first_message TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    cursor.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_conversations_file_path ON conversations(file_path)')
    
    # 对话轮次表（用于精确搜索）
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS turns (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            conversation_id INTEGER,
            turn_index INTEGER,
            time TEXT,
            first_line TEXT,
            FOREIGN KEY (conversation_id) REFERENCES conversations(id)
        )
    ''')
    
    # 全文搜索索引
    cursor.execute('''
        CREATE VIRTUAL TABLE IF NOT EXISTS conversations_fts USING fts5(
            title, first_message, content='conversations', content_rowid='id'
        )
    ''')
    
    conn.commit()
    conn.close()


def add_conversation(db_path: Path, metadata_path: str, file_path: str):
    """添加对话记录到索引"""
    with open(metadata_path, 'r', encoding='utf-8') as f:
        metadata = json.load(f)
    
    title = metadata.get('conversation_title', 'Untitled')
    project_path = metadata.get('project_path', '')
    archive_time = metadata.get('archive_time', datetime.now().strftime('%Y-%m-%d %H:%M'))
    turns = metadata.get('turns', [])
    first_message = turns[0].get('first_line', '') if turns else ''
    
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # 幂等更新：同一归档文件重复入库时覆盖旧记录
    cursor.execute('SELECT id FROM conversations WHERE file_path = ?', (file_path,))
    existing = cursor.fetchone()
    if existing:
        existing_id = existing[0]
        cursor.execute('DELETE FROM turns WHERE conversation_id = ?', (existing_id,))
        cursor.execute('DELETE FROM conversations_fts WHERE rowid = ?', (existing_id,))
        cursor.execute('DELETE FROM conversations WHERE id = ?', (existing_id,))
    
    # 插入主记录
    cursor.execute('''
        INSERT INTO conversations (title, project_path, file_path, archive_time, turn_count, first_message)
        VALUES (?, ?, ?, ?, ?, ?)
    ''', (title, project_path, file_path, archive_time, len(turns), first_message))
    
    conversation_id = cursor.lastrowid
    
    # 插入轮次记录
    for turn in turns:
        cursor.execute('''
            INSERT INTO turns (conversation_id, turn_index, time, first_line)
            VALUES (?, ?, ?, ?)
        ''', (conversation_id, turn.get('index'), turn.get('time'), turn.get('first_line')))
    
    # 更新全文索引
    cursor.execute('''
        INSERT INTO conversations_fts (rowid, title, first_message)
        VALUES (?, ?, ?)
    ''', (conversation_id, title, first_message))
    
    conn.commit()
    conn.close()
    
    # 导出 JSON 备份
    export_json_backup(db_path)
    
    print(f"✅ 已添加到索引: {title}")
    print(f"   ID: {conversation_id}")
    print(f"   轮次: {len(turns)}")


def export_json_backup(db_path: Path):
    """导出 JSON 备份文件"""
    backup_path = db_path.parent / 'index_backup.json'
    
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    cursor.execute('''
        SELECT id, title, project_path, file_path, archive_time, turn_count, first_message
        FROM conversations
        ORDER BY archive_time DESC
    ''')
    
    rows = cursor.fetchall()
    conn.close()
    
    backup_data = {
        "exported_at": datetime.now().strftime('%Y-%m-%d %H:%M'),
        "total_count": len(rows),
        "conversations": [
            {
                "id": r[0],
                "title": r[1],
                "project_path": r[2],
                "file_path": r[3],
                "archive_time": r[4],
                "turn_count": r[5],
                "first_message": r[6]
            }
            for r in rows
        ]
    }
    
    with open(backup_path, 'w', encoding='utf-8') as f:
        json.dump(backup_data, f, ensure_ascii=False, indent=2)




def search_conversations(db_path: Path, keyword: str = None, date_range: str = None, project: str = None):
    """搜索对话记录"""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    filters = []
    params = []

    if keyword:
        sql = '''
            SELECT c.id, c.title, c.archive_time, c.turn_count, c.file_path, c.first_message
            FROM conversations c
            JOIN conversations_fts fts ON c.id = fts.rowid
            WHERE conversations_fts MATCH ?
        '''
        params.append(keyword)
        if project:
            sql += ' AND c.project_path LIKE ?'
            params.append(f'%{project}%')
        if date_range:
            start_date, end_date = date_range.split(',')
            sql += ' AND c.archive_time BETWEEN ? AND ?'
            params.extend([start_date, end_date + ' 23:59'])
        sql += ' ORDER BY c.archive_time DESC'
        cursor.execute(sql, params)
    else:
        if date_range:
            start_date, end_date = date_range.split(',')
            filters.append('archive_time BETWEEN ? AND ?')
            params.extend([start_date, end_date + ' 23:59'])
        if project:
            filters.append('project_path LIKE ?')
            params.append(f'%{project}%')

        sql = '''
            SELECT id, title, archive_time, turn_count, file_path, first_message
            FROM conversations
        '''
        if filters:
            sql += ' WHERE ' + ' AND '.join(filters)
        sql += ' ORDER BY archive_time DESC LIMIT 20'
        cursor.execute(sql, params)
    
    results = cursor.fetchall()
    conn.close()
    
    if not results:
        print("未找到匹配的对话记录")
        return
    
    print(f"找到 {len(results)} 条记录:\n")
    for row in results:
        id_, title, time, turns, path, first_msg = row
        print(f"[{id_}] {title}")
        print(f"    时间: {time} | 轮次: {turns}")
        print(f"    首句: {first_msg[:50]}..." if len(first_msg) > 50 else f"    首句: {first_msg}")
        print(f"    文件: {path}")
        print()


def list_recent(db_path: Path, limit: int = 10):
    """列出最近的对话记录"""
    search_conversations(db_path)


def main():
    parser = argparse.ArgumentParser(description='对话索引数据库管理')
    parser.add_argument('--action', required=True, choices=['add', 'search', 'list', 'init'],
                        help='操作类型')
    parser.add_argument('--metadata', help='元数据 JSON 文件路径 (add 操作需要)')
    parser.add_argument('--file', help='归档文件路径 (add 操作需要)')
    parser.add_argument('--keyword', help='搜索关键词 (search 操作)')
    parser.add_argument('--date-range', help='日期范围，格式: 开始,结束 (search 操作)')
    parser.add_argument('--project', help='按项目路径过滤 (search 操作)')
    parser.add_argument('--data-dir', help='AMS data 目录（默认 ~/.ai-memory/data）')
    args = parser.parse_args()
    
    data_dir = get_data_dir(args.data_dir)
    db_path = get_db_path(data_dir)

    # 确保数据库已初始化
    init_db(db_path)
    
    if args.action == 'init':
        print(f"✅ 数据库已初始化: {db_path}")
    elif args.action == 'add':
        if not args.metadata or not args.file:
            print("错误: add 操作需要 --metadata 和 --file 参数")
            return
        add_conversation(db_path, args.metadata, args.file)
    elif args.action == 'search':
        search_conversations(db_path, keyword=args.keyword, date_range=args.date_range, project=args.project)
    elif args.action == 'list':
        list_recent(db_path)


if __name__ == '__main__':
    main()
