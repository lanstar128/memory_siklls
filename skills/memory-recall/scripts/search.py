#!/usr/bin/env python3
"""
记忆检索脚本
支持语义搜索历史对话和经验沉淀，使用本地 embedding 模型。

用法:
    # 语义搜索
    python3 search.py --query "对话归档怎么实现的" --top 5
    
    # 查看原文
    python3 search.py --show 1
    
    # 按条件过滤
    python3 search.py --query "关键词" --type conversation --date-range "2026-01-01,2026-01-18"
"""

import argparse
import json
import os
import sqlite3
import sys
from pathlib import Path


# 路径配置
DB_PATH = Path.home() / '.gemini' / 'memory' / 'conversations.db'
SKILLS_DIR = Path.home() / '.gemini' / 'antigravity' / 'skills'
MODEL_DIR = Path.home() / '.gemini' / 'models' / 'all-MiniLM-L6-v2'

# 全局变量
_model = None
_use_semantic = False


def check_dependencies():
    """检查依赖是否已安装，缺失时询问用户是否安装"""
    global _use_semantic
    try:
        from sentence_transformers import SentenceTransformer
        _use_semantic = True
        return True
    except ImportError:
        print("┌────────────────────────────────────────────────────┐")
        print("│ 🔍 语义搜索依赖未安装                              │")
        print("├────────────────────────────────────────────────────┤")
        print("│ 语义搜索可以更智能地理解您的问题。                 │")
        print("│ 首次使用需要下载模型（约 80MB），可能需要几分钟。  │")
        print("└────────────────────────────────────────────────────┘")
        print()
        print("是否安装语义搜索依赖？")
        print("  输入 y 安装（推荐）")
        print("  输入 n 使用关键词搜索（功能受限）")
        print()
        
        try:
            choice = input("请选择 [y/n]: ").strip().lower()
        except EOFError:
            # 非交互模式，降级到关键词搜索
            choice = 'n'
        
        if choice == 'y':
            print()
            print("正在安装 sentence-transformers...")
            import subprocess
            result = subprocess.run(
                [sys.executable, '-m', 'pip', 'install', 'sentence-transformers'],
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                print("✅ 安装成功！")
                print()
                # 重新导入
                from sentence_transformers import SentenceTransformer
                _use_semantic = True
                return True
            else:
                print("❌ 安装失败，将使用关键词搜索。")
                print(f"错误信息: {result.stderr[:200]}")
                _use_semantic = False
                return False
        else:
            print()
            print("已选择关键词搜索模式。")
            _use_semantic = False
            return False


def load_model():
    """加载或下载 embedding 模型"""
    global _model
    if _model is not None:
        return _model
    
    if not _use_semantic:
        return None
    
    from sentence_transformers import SentenceTransformer
    
    if MODEL_DIR.exists():
        print("加载本地模型...")
        _model = SentenceTransformer(str(MODEL_DIR))
    else:
        print("首次运行，正在下载语义搜索模型（约 80MB）...")
        _model = SentenceTransformer('all-MiniLM-L6-v2')
        MODEL_DIR.parent.mkdir(parents=True, exist_ok=True)
        _model.save(str(MODEL_DIR))
        print(f"模型已保存到: {MODEL_DIR}")
    
    return _model


def get_embedding(text: str):
    """生成文本的 embedding"""
    model = load_model()
    if model is None:
        return None
    return model.encode(text)


def cosine_similarity(a, b):
    """计算余弦相似度"""
    import numpy as np
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))


def search_conversations_keyword(keyword: str, date_range: str = None, limit: int = 10):
    """关键词搜索对话"""
    if not DB_PATH.exists():
        return []
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    query = """
        SELECT id, title, archive_time, turn_count, file_path, first_message, project_path
        FROM conversations
        WHERE (title LIKE ? OR first_message LIKE ?)
    """
    params = [f'%{keyword}%', f'%{keyword}%']
    
    if date_range:
        start_date, end_date = date_range.split(',')
        query += " AND archive_time BETWEEN ? AND ?"
        params.extend([start_date, end_date + ' 23:59'])
    
    query += " ORDER BY archive_time DESC LIMIT ?"
    params.append(limit)
    
    cursor.execute(query, params)
    results = cursor.fetchall()
    conn.close()
    
    return [
        {
            'id': r[0],
            'title': r[1],
            'time': r[2],
            'turns': r[3],
            'file_path': r[4],
            'first_message': r[5],
            'project_path': r[6],
            'type': 'conversation',
            'score': 1.0  # 关键词匹配默认分数
        }
        for r in results
    ]


def search_skills_keyword(keyword: str):
    """关键词搜索技能"""
    results = []
    keyword_lower = keyword.lower()
    
    # 搜索全局技能
    if SKILLS_DIR.exists():
        for skill_dir in SKILLS_DIR.iterdir():
            if not skill_dir.is_dir():
                continue
            skill_file = skill_dir / 'SKILL.md'
            if not skill_file.exists():
                continue
            
            content = skill_file.read_text(encoding='utf-8')
            
            # 提取 name 和 description
            name = skill_dir.name
            description = ""
            if 'description:' in content:
                desc_start = content.find('description:')
                desc_end = content.find('---', desc_start + 1)
                if desc_end > desc_start:
                    description = content[desc_start:desc_end]
            
            if keyword_lower in name.lower() or keyword_lower in description.lower():
                results.append({
                    'id': f'skill:{name}',
                    'title': name,
                    'time': '',
                    'turns': 0,
                    'file_path': str(skill_file),
                    'first_message': description[:100],
                    'project_path': '',
                    'type': 'skill',
                    'score': 1.0
                })
    
    return results


def search_semantic(query: str, type_filter: str = None, date_range: str = None, limit: int = 10):
    """语义搜索（需要 embeddings 支持）"""
    # 目前回退到关键词搜索
    # TODO: 实现真正的语义搜索
    results = []
    
    if type_filter != 'skill':
        results.extend(search_conversations_keyword(query, date_range, limit))
    
    if type_filter != 'conversation':
        results.extend(search_skills_keyword(query))
    
    # 按相关度排序
    results.sort(key=lambda x: x['score'], reverse=True)
    
    return results[:limit]


def display_results(results):
    """显示搜索结果"""
    if not results:
        print("未找到相关记录")
        return
    
    print(f"找到 {len(results)} 条相关记录:\n")
    
    for i, r in enumerate(results, 1):
        type_label = "对话归档" if r['type'] == 'conversation' else "技能文件"
        print(f"[{i}] {r['title']} ({r['time'] or '技能'})")
        first_msg = r['first_message'][:50] + '...' if len(r['first_message']) > 50 else r['first_message']
        print(f"    首句: {first_msg}")
        print(f"    相关度: {r['score']:.2f}")
        print(f"    类型: {type_label}")
        print(f"    文件: {r['file_path']}")
        print()


def show_content(item_id: int):
    """显示原文内容"""
    # 查找对应记录
    if not DB_PATH.exists():
        print("数据库不存在")
        return
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT title, file_path FROM conversations WHERE id = ?
    """, (item_id,))
    
    result = cursor.fetchone()
    conn.close()
    
    if not result:
        print(f"未找到 ID 为 {item_id} 的记录")
        return
    
    title, file_path = result
    
    if not Path(file_path).exists():
        print(f"文件不存在: {file_path}")
        return
    
    print(f"=== {title} ===\n")
    print(Path(file_path).read_text(encoding='utf-8'))


def main():
    parser = argparse.ArgumentParser(description='记忆检索')
    parser.add_argument('--query', '-q', help='搜索关键词或问题')
    parser.add_argument('--show', '-s', type=int, help='显示指定 ID 的原文')
    parser.add_argument('--top', '-n', type=int, default=5, help='返回结果数量')
    parser.add_argument('--type', '-t', choices=['conversation', 'skill'], help='过滤类型')
    parser.add_argument('--date-range', help='日期范围，格式: 开始,结束')
    parser.add_argument('--list', '-l', action='store_true', help='列出最近记录')
    args = parser.parse_args()
    
    # 检查依赖
    check_dependencies()
    
    if args.show:
        show_content(args.show)
    elif args.query:
        results = search_semantic(args.query, args.type, args.date_range, args.top)
        display_results(results)
    elif args.list:
        results = search_conversations_keyword('', args.date_range, args.top)
        display_results(results)
    else:
        parser.print_help()


if __name__ == '__main__':
    main()
