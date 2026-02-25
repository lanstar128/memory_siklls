#!/usr/bin/env python3
"""
Export Codex CLI session JSONL to a Markdown archive plus metadata JSON.
"""

import argparse
import json
import os
import re
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple


def get_data_dir() -> Path:
    """Resolve the AMS data dir, defaulting to ~/.ai-memory/data."""
    data_dir = os.environ.get('AI_MEMORY_DATA_DIR') or os.environ.get('AMS_DATA_DIR')
    if data_dir:
        return Path(data_dir).expanduser()

    memory_root = os.environ.get('AI_MEMORY_ROOT') or os.environ.get('AMS_MEMORY_ROOT')
    if memory_root:
        return Path(memory_root).expanduser() / 'data'

    return Path.home() / '.ai-memory' / 'data'


def parse_timestamp(raw_ts: Optional[str]) -> Optional[datetime]:
    if not raw_ts:
        return None
    try:
        if raw_ts.endswith('Z'):
            raw_ts = raw_ts[:-1] + '+00:00'
        return datetime.fromisoformat(raw_ts)
    except ValueError:
        return None


def format_timestamp(raw_ts: Optional[str]) -> str:
    dt = parse_timestamp(raw_ts)
    if not dt:
        return raw_ts or ''
    return dt.astimezone().strftime('%Y-%m-%d %H:%M')


def sanitize_filename(title: str) -> str:
    sanitized = re.sub(r'[<>:"/\\|?*]', '-', title)
    return sanitized[:100]


def infer_latest_session() -> Optional[Path]:
    sessions_root = Path.home() / '.codex' / 'sessions'
    if not sessions_root.exists():
        return None
    candidates = sorted(
        sessions_root.rglob('*.jsonl'),
        key=lambda p: p.stat().st_mtime,
        reverse=True,
    )
    return candidates[0] if candidates else None


def load_session(session_path: Path) -> Tuple[List[Dict[str, str]], Dict[str, str]]:
    messages: List[Dict[str, str]] = []
    session_meta: Dict[str, str] = {}

    with session_path.open('r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue

            if obj.get('type') == 'session_meta':
                session_meta = obj.get('payload', {}) or session_meta

            if obj.get('type') != 'response_item':
                continue
            payload = obj.get('payload') or {}
            if payload.get('type') != 'message':
                continue
            role = payload.get('role')
            if role not in ('user', 'assistant'):
                continue

            content_items = payload.get('content', [])
            text_parts: List[str] = []
            for item in content_items:
                if not isinstance(item, dict):
                    continue
                text = item.get('text')
                if text:
                    text_parts.append(text)
                elif item.get('type') == 'image':
                    text_parts.append('[[image omitted]]')

            text = '\n'.join(part for part in text_parts if part).strip()
            if not text:
                continue

            messages.append({
                'role': role,
                'text': text,
                'timestamp': obj.get('timestamp', ''),
            })

    return messages, session_meta


def build_markdown(
    title: str,
    session_id: str,
    project_path: str,
    archive_time: str,
    messages: List[Dict[str, str]],
) -> str:
    header = [
        '---',
        f'archived: {archive_time}',
        'source: codex-session',
        f'session_id: {session_id}',
        f'project_path: {project_path}',
        '---',
        '',
        f'# {title}',
        '',
        '## Conversation',
        '',
    ]
    body: List[str] = []
    for msg in messages:
        label = 'User Input' if msg['role'] == 'user' else 'Assistant Output'
        ts = format_timestamp(msg.get('timestamp'))
        suffix = f' [{ts}]' if ts else ''
        body.append(f'### {label}{suffix}')
        body.append('')
        body.append(msg['text'])
        body.append('')

    return '\n'.join(header + body).rstrip() + '\n'


def build_metadata(
    title: str,
    archive_time: str,
    project_path: str,
    messages: List[Dict[str, str]],
) -> Dict[str, object]:
    turns = []
    user_index = 1
    for msg in messages:
        if msg['role'] != 'user':
            continue
        text = msg['text'].strip()
        first_line = text.splitlines()[0] if text else ''
        turns.append({
            'index': user_index,
            'time': format_timestamp(msg.get('timestamp')),
            'first_line': first_line[:200],
        })
        user_index += 1

    return {
        'conversation_title': title,
        'archive_time': archive_time,
        'project_path': project_path,
        'turns': turns,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description='Export Codex session JSONL to Markdown')
    parser.add_argument('--session', help='Path to a Codex session JSONL file')
    parser.add_argument('--latest', action='store_true', help='Use the latest session')
    parser.add_argument('--title', help='Conversation title override')
    parser.add_argument('--out-dir', help='Legacy memory root (stores files under <out-dir>/conversations)')
    parser.add_argument('--data-dir', help='AMS data directory (defaults to ~/.ai-memory/data)')
    parser.add_argument('--metadata-out', help='Metadata JSON output path')
    args = parser.parse_args()

    session_path = Path(args.session).expanduser() if args.session else None
    if args.latest or session_path is None:
        inferred = infer_latest_session()
        if inferred is None:
            raise SystemExit('No Codex sessions found under ~/.codex/sessions')
        session_path = inferred

    if not session_path.exists():
        raise SystemExit(f'Session file not found: {session_path}')

    messages, session_meta = load_session(session_path)
    if not messages:
        raise SystemExit('No messages found in session file')

    session_id = str(session_meta.get('id', session_path.stem))
    project_path = str(session_meta.get('cwd', os.getcwd()))

    archive_dt = parse_timestamp(messages[-1].get('timestamp')) or datetime.now().astimezone()
    archive_time = archive_dt.strftime('%Y-%m-%d %H:%M')
    date_prefix = archive_dt.strftime('%Y-%m-%d')
    month_dir = archive_dt.strftime('%Y-%m')

    title = args.title or f'Codex Session {session_id}'

    if args.data_dir:
        data_dir = Path(args.data_dir).expanduser()
    elif args.out_dir:
        data_dir = Path(args.out_dir).expanduser()
    else:
        data_dir = get_data_dir()

    output_dir = data_dir / 'conversations' / month_dir
    output_dir.mkdir(parents=True, exist_ok=True)

    output_filename = f'{date_prefix}_{sanitize_filename(title)}.md'
    output_path = output_dir / output_filename

    markdown = build_markdown(title, session_id, project_path, archive_time, messages)
    output_path.write_text(markdown, encoding='utf-8')

    metadata = build_metadata(title, archive_time, project_path, messages)
    metadata_path = Path(args.metadata_out).expanduser() if args.metadata_out else output_path.with_suffix('.json')
    metadata_path.write_text(json.dumps(metadata, ensure_ascii=False, indent=2), encoding='utf-8')

    print(f'OK Exported Markdown: {output_path}')
    print(f'OK Metadata JSON: {metadata_path}')
    print(f'   Messages: {len(messages)} | User turns: {len(metadata["turns"])}')


if __name__ == '__main__':
    main()
