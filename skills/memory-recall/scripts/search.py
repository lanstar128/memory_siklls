#!/usr/bin/env python3
"""
记忆检索脚本
支持检索历史对话、知识沉淀和技能描述；在可用时使用本地 embedding 做语义重排。
"""

import argparse
import json
import os
import re
import sqlite3
import sys
from pathlib import Path
from typing import Dict, List, Optional


# 全局变量（运行时按参数覆盖路径）
_model = None
_use_semantic = False
_DATA_DIR: Optional[Path] = None
_SKILLS_DIR: Optional[Path] = None
_MODEL_DIR: Optional[Path] = None
_DB_PATH: Optional[Path] = None
_CONVERSATIONS_DIR: Optional[Path] = None
_KNOWLEDGE_DIR: Optional[Path] = None


def resolve_paths(data_dir: Optional[str] = None, skills_dir: Optional[str] = None, models_dir: Optional[str] = None) -> None:
    """Resolve AMS directories with CLI > env > defaults precedence."""
    global _DATA_DIR, _SKILLS_DIR, _MODEL_DIR, _DB_PATH, _CONVERSATIONS_DIR, _KNOWLEDGE_DIR

    env_data_dir = os.environ.get('AI_MEMORY_DATA_DIR') or os.environ.get('AMS_DATA_DIR')
    env_memory_root = os.environ.get('AI_MEMORY_ROOT') or os.environ.get('AMS_MEMORY_ROOT')

    if data_dir:
        _DATA_DIR = Path(data_dir).expanduser()
    elif env_data_dir:
        _DATA_DIR = Path(env_data_dir).expanduser()
    elif env_memory_root:
        _DATA_DIR = Path(env_memory_root).expanduser() / 'data'
    else:
        _DATA_DIR = Path.home() / '.ai-memory' / 'data'

    memory_root = _DATA_DIR.parent if _DATA_DIR.name == 'data' else (_DATA_DIR / '..').resolve()

    if skills_dir:
        _SKILLS_DIR = Path(skills_dir).expanduser()
    else:
        env_skills_dir = os.environ.get('AI_MEMORY_SKILLS_DIR') or os.environ.get('AMS_SKILLS_DIR')
        _SKILLS_DIR = Path(env_skills_dir).expanduser() if env_skills_dir else memory_root / 'skills' / 'skills'

    if models_dir:
        _MODEL_DIR = Path(models_dir).expanduser()
    else:
        env_models_dir = os.environ.get('AI_MEMORY_MODELS_DIR') or os.environ.get('AMS_MODELS_DIR')
        _MODEL_DIR = Path(env_models_dir).expanduser() if env_models_dir else memory_root / 'models' / 'all-MiniLM-L6-v2'

    _DB_PATH = _DATA_DIR / 'conversations.db'
    _CONVERSATIONS_DIR = _DATA_DIR / 'conversations'
    _KNOWLEDGE_DIR = _DATA_DIR / 'knowledge'


def check_dependencies(allow_prompt: bool = True, allow_auto_install: bool = False) -> bool:
    """检查语义检索依赖；不可用时降级到关键词检索。"""
    global _use_semantic
    try:
        from sentence_transformers import SentenceTransformer  # noqa: F401
        _use_semantic = True
        return True
    except ImportError:
        _use_semantic = False

    if not allow_prompt:
        return False

    print("┌────────────────────────────────────────────────────┐")
    print("│ 🔍 语义搜索依赖未安装                              │")
    print("├────────────────────────────────────────────────────┤")
    print("│ 将回退到关键词检索。                               │")
    print("│ 如需语义搜索，可安装 sentence-transformers。        │")
    print("└────────────────────────────────────────────────────┘")
    print()

    if not allow_auto_install:
        print("提示：加上 --install-deps 可在本机自动安装依赖。")
        return False

    try:
        choice = input("是否安装语义搜索依赖？[y/N]: ").strip().lower()
    except EOFError:
        choice = 'n'

    if choice != 'y':
        return False

    print("正在安装 sentence-transformers...")
    import subprocess
    result = subprocess.run(
        [sys.executable, '-m', 'pip', 'install', 'sentence-transformers'],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print("❌ 安装失败，将使用关键词搜索。")
        print(result.stderr[:200])
        return False

    try:
        from sentence_transformers import SentenceTransformer  # noqa: F401
        _use_semantic = True
        return True
    except ImportError:
        _use_semantic = False
        return False


def load_model():
    """加载或下载 embedding 模型。"""
    global _model
    if _model is not None:
        return _model
    if not _use_semantic:
        return None

    from sentence_transformers import SentenceTransformer

    assert _MODEL_DIR is not None
    if _MODEL_DIR.exists():
        print("加载本地模型...")
        _model = SentenceTransformer(str(_MODEL_DIR))
    else:
        print("首次运行，正在下载语义搜索模型（约 80MB）...")
        _model = SentenceTransformer('all-MiniLM-L6-v2')
        _MODEL_DIR.parent.mkdir(parents=True, exist_ok=True)
        _model.save(str(_MODEL_DIR))
        print(f"模型已保存到: {_MODEL_DIR}")

    return _model


def get_embedding(text: str):
    model = load_model()
    if model is None:
        return None
    return model.encode(text)


def cosine_similarity(a, b) -> float:
    try:
        import numpy as np
        return float(np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b)))
    except Exception:
        # 兼容 list 类型 embedding 的纯 Python 计算
        dot = sum(x * y for x, y in zip(a, b))
        norm_a = sum(x * x for x in a) ** 0.5
        norm_b = sum(y * y for y in b) ** 0.5
        if norm_a == 0 or norm_b == 0:
            return 0.0
        return float(dot / (norm_a * norm_b))


def parse_date_range(date_range: Optional[str]):
    if not date_range:
        return None, None
    try:
        start_date, end_date = [v.strip() for v in date_range.split(',', 1)]
        return start_date, end_date
    except ValueError:
        return None, None


def within_date_range(time_str: str, date_range: Optional[str]) -> bool:
    if not date_range:
        return True
    start_date, end_date = parse_date_range(date_range)
    if not start_date or not end_date:
        return True
    day = (time_str or '')[:10]
    if not day:
        return False
    return start_date <= day <= end_date


def normalize_result(record: Dict[str, object]) -> Dict[str, object]:
    record.setdefault('time', '')
    record.setdefault('turns', 0)
    record.setdefault('first_message', '')
    record.setdefault('project_path', '')
    record.setdefault('score', 1.0)
    return record


def parse_conversation_markdown(md_file: Path) -> Optional[Dict[str, object]]:
    try:
        content = md_file.read_text(encoding='utf-8')
    except Exception:
        return None

    title_match = re.search(r'^#\s+(.+)$', content, flags=re.MULTILINE)
    archived_match = re.search(r'^archived:\s*(.+)$', content, flags=re.MULTILINE)
    project_match = re.search(r'^project_path:\s*(.+)$', content, flags=re.MULTILINE)
    first_user_match = re.search(r'^###\s+User Input(?:\s+\[[^\]]+\])?\n\n(.+?)(?:\n###|\Z)', content, flags=re.MULTILINE | re.DOTALL)
    turns = len(re.findall(r'^###\s+User Input', content, flags=re.MULTILINE))

    title = title_match.group(1).strip() if title_match else md_file.stem
    first_message = ''
    if first_user_match:
        first_message = first_user_match.group(1).strip().splitlines()[0][:200]

    return normalize_result({
        'id': f'conversation-file:{md_file}',
        'title': title,
        'time': archived_match.group(1).strip() if archived_match else '',
        'turns': turns,
        'file_path': str(md_file),
        'first_message': first_message,
        'project_path': project_match.group(1).strip() if project_match else '',
        'type': 'conversation',
        'score': 1.0,
    })


def search_conversations_keyword(keyword: str, date_range: str = None, project: str = None, limit: int = 10):
    """关键词搜索对话；优先使用 SQLite，缺失时回退扫描 Markdown。"""
    assert _DB_PATH is not None and _CONVERSATIONS_DIR is not None

    if _DB_PATH.exists():
        conn = sqlite3.connect(_DB_PATH)
        cursor = conn.cursor()

        query = """
            SELECT id, title, archive_time, turn_count, file_path, first_message, project_path
            FROM conversations
            WHERE (title LIKE ? OR first_message LIKE ?)
        """
        params = [f'%{keyword}%', f'%{keyword}%']

        if date_range:
            start_date, end_date = parse_date_range(date_range)
            if start_date and end_date:
                query += " AND archive_time BETWEEN ? AND ?"
                params.extend([start_date, end_date + ' 23:59'])

        if project:
            query += ' AND project_path LIKE ?'
            params.append(f'%{project}%')

        query += " ORDER BY archive_time DESC LIMIT ?"
        params.append(limit)

        cursor.execute(query, params)
        rows = cursor.fetchall()
        conn.close()

        return [
            normalize_result({
                'id': r[0],
                'title': r[1],
                'time': r[2],
                'turns': r[3],
                'file_path': r[4],
                'first_message': r[5],
                'project_path': r[6],
                'type': 'conversation',
                'score': 1.0,
            })
            for r in rows
        ]

    results: List[Dict[str, object]] = []
    keyword_lower = keyword.lower()
    if _CONVERSATIONS_DIR.exists():
        for md_file in sorted(_CONVERSATIONS_DIR.rglob('*.md')):
            record = parse_conversation_markdown(md_file)
            if not record:
                continue
            haystack = f"{record['title']}\n{record['first_message']}".lower()
            if keyword_lower and keyword_lower not in haystack:
                continue
            if project and project not in str(record.get('project_path', '')):
                continue
            if not within_date_range(str(record.get('time', '')), date_range):
                continue
            results.append(record)
    results.sort(key=lambda x: str(x.get('time', '')), reverse=True)
    return results[:limit]


def search_skills_keyword(keyword: str):
    results: List[Dict[str, object]] = []
    keyword_lower = keyword.lower()

    assert _SKILLS_DIR is not None
    if _SKILLS_DIR.exists():
        for skill_dir in _SKILLS_DIR.iterdir():
            if not skill_dir.is_dir():
                continue
            skill_file = skill_dir / 'SKILL.md'
            if not skill_file.exists():
                continue

            try:
                content = skill_file.read_text(encoding='utf-8')
            except Exception:
                continue

            name = skill_dir.name
            description = ''
            if 'description:' in content:
                desc_start = content.find('description:')
                desc_end = content.find('---', desc_start + 1)
                if desc_end > desc_start:
                    description = content[desc_start:desc_end]

            if not keyword_lower or keyword_lower in name.lower() or keyword_lower in description.lower():
                results.append(normalize_result({
                    'id': f'skill:{name}',
                    'title': name,
                    'file_path': str(skill_file),
                    'first_message': description[:200],
                    'type': 'skill',
                    'score': 1.0,
                }))

    return results


def search_knowledge_keyword(keyword: str):
    results: List[Dict[str, object]] = []
    keyword_lower = keyword.lower()

    assert _KNOWLEDGE_DIR is not None
    if not _KNOWLEDGE_DIR.exists():
        return results

    for md_file in _KNOWLEDGE_DIR.rglob('*.md'):
        try:
            content = md_file.read_text(encoding='utf-8')
        except Exception:
            continue

        title = md_file.stem
        if keyword_lower and keyword_lower not in title.lower() and keyword_lower not in content.lower():
            continue

        desc = content[:200].replace('\n', ' ')
        results.append(normalize_result({
            'id': f'knowledge:{title}',
            'title': title,
            'file_path': str(md_file),
            'first_message': desc,
            'type': 'knowledge',
            'score': 1.0,
        }))

    return results


def semantic_rerank(results: List[Dict[str, object]], query: str) -> List[Dict[str, object]]:
    if not _use_semantic or not results:
        return results

    query_vec = get_embedding(query)
    if query_vec is None:
        return results

    for item in results:
        text = ' '.join([
            str(item.get('title', '')),
            str(item.get('first_message', '')),
            str(item.get('project_path', '')),
        ]).strip()
        if not text:
            item['score'] = float(item.get('score', 0.0))
            continue
        vec = get_embedding(text)
        if vec is None:
            continue
        item['score'] = cosine_similarity(query_vec, vec)

    results.sort(key=lambda x: float(x.get('score', 0.0)), reverse=True)
    return results


def search_semantic(query: str, type_filter: str = None, date_range: str = None, project: str = None, limit: int = 10):
    """统一检索；依赖可用时用 embeddings 做重排，否则退化为关键词匹配。"""
    results: List[Dict[str, object]] = []

    if type_filter is None or type_filter == 'conversation':
        results.extend(search_conversations_keyword(query, date_range, project, max(limit * 3, 20)))

    if type_filter is None or type_filter == 'knowledge':
        results.extend(search_knowledge_keyword(query))

    if type_filter is None or type_filter == 'skill':
        results.extend(search_skills_keyword(query))

    if _use_semantic:
        results = semantic_rerank(results, query)
    else:
        results.sort(key=lambda x: (float(x.get('score', 0.0)), str(x.get('time', ''))), reverse=True)

    return results[:limit]


def display_results(results):
    if not results:
        print('未找到相关记录')
        return

    print(f'找到 {len(results)} 条相关记录:\n')
    type_labels = {
        'conversation': '对话归档',
        'knowledge': '知识沉淀',
        'skill': '技能文件',
    }

    for i, r in enumerate(results, 1):
        type_label = type_labels.get(str(r.get('type')), str(r.get('type')))
        print(f"[{i}] {r.get('title')} ({r.get('time') or type_label})")
        first_msg = str(r.get('first_message', ''))
        if len(first_msg) > 70:
            first_msg = first_msg[:70] + '...'
        print(f'    首句: {first_msg}')
        print(f"    相关度: {float(r.get('score', 0.0)):.2f}")
        print(f'    类型: {type_label}')
        print(f"    文件: {r.get('file_path')}")
        print()


def show_content(item_id: int):
    assert _DB_PATH is not None
    if not _DB_PATH.exists():
        print('数据库不存在')
        return

    conn = sqlite3.connect(_DB_PATH)
    cursor = conn.cursor()
    cursor.execute('SELECT title, file_path FROM conversations WHERE id = ?', (item_id,))
    result = cursor.fetchone()
    conn.close()

    if not result:
        print(f'未找到 ID 为 {item_id} 的记录')
        return

    title, file_path = result
    path = Path(file_path)
    if not path.exists():
        print(f'文件不存在: {file_path}')
        return

    print(f'=== {title} ===\n')
    print(path.read_text(encoding='utf-8'))


def main():
    parser = argparse.ArgumentParser(description='记忆检索')
    parser.add_argument('--query', '-q', help='搜索关键词或问题')
    parser.add_argument('--show', '-s', type=int, help='显示指定 ID 的原文（对话索引 ID）')
    parser.add_argument('--top', '-n', type=int, default=5, help='返回结果数量')
    parser.add_argument('--type', '-t', choices=['conversation', 'knowledge', 'skill'], help='过滤类型')
    parser.add_argument('--date-range', help='日期范围，格式: 开始,结束')
    parser.add_argument('--project', help='按项目路径过滤（对话）')
    parser.add_argument('--list', '-l', action='store_true', help='列出最近记录')
    parser.add_argument('--data-dir', help='AMS data 目录（默认 ~/.ai-memory/data）')
    parser.add_argument('--skills-dir', help='技能目录（默认 ~/.ai-memory/skills/skills）')
    parser.add_argument('--models-dir', help='embedding 模型目录（默认 ~/.ai-memory/models/all-MiniLM-L6-v2）')
    parser.add_argument('--keyword-only', action='store_true', help='禁用语义重排，直接关键词检索')
    parser.add_argument('--install-deps', action='store_true', help='允许交互安装语义检索依赖')
    args = parser.parse_args()

    resolve_paths(args.data_dir, args.skills_dir, args.models_dir)

    if args.keyword_only:
        global _use_semantic
        _use_semantic = False
    else:
        interactive = sys.stdin.isatty()
        check_dependencies(allow_prompt=interactive, allow_auto_install=args.install_deps)

    if args.show:
        show_content(args.show)
    elif args.query:
        results = search_semantic(args.query, args.type, args.date_range, args.project, args.top)
        display_results(results)
    elif args.list:
        results = search_conversations_keyword('', args.date_range, args.project, args.top)
        display_results(results)
    else:
        parser.print_help()


if __name__ == '__main__':
    main()
