# 🧠 AI Memory System (AMS)

<div align="center">

**Build a persistent, cross-platform, privacy-first "Second Brain" for your AI assistants.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

[English](./README.md) | [简体中文](./README_zh-CN.md)

</div>

**AI Memory System (AMS)** is an open-source framework designed to give your AI assistants (Gemini, Claude, ChatGPT, etc.) a unified, long-term memory. It bridges the gap between different AI tools, allowing them to share context, knowledge, and preferences across all your devices securely.

---

## 🌟 Key Features

- **🔒 Privacy First Architecture**
  - **Your Data Stays Yours**: Adopts a unique "Code (Public) + Data (Private)" dual-repository strategy.
  - **Zero Leakage**: All conversations, knowledge, and secrets are stored in your own **Private GitHub Repository**. Only the skill logic is shared.

- **⚡️ Smart Aggregation**
  - **Best of Both Worlds**: Automatically merges official, community-verified skills with your own private, custom skills locally.
  - **Priority Override**: Ensures core system stability by prioritizing official updates (`memory-sync`) while preserving your unique private tools (`my-custom-scraper`).

- **🚀 Cross-Platform & Cross-Tool**
  - **Any OS**: Seamless experience on macOS, Windows, Linux, and Android (via Termux).
  - **Any Tool**: Native support for **Gemini CLI**, **Claude Code**, **Antigravity**, **iFlow**, and **Codex**.
  - **IDE Ready**: Includes configuration guides for VS Code, Cursor, and JetBrains.

- **🔄 Seamless Synchronization**
  - **One Command**: Just say "Sync Memory" to `pull -> commit -> push`.
  - **Conflict Free**: Automatically handles multi-device synchronization logic, keeping your brain in sync whether you're on your phone or desktop.

---

## 📦 Quick Start

### 1. Preparation
Create a **Private Repository** on GitHub named `my-ai-memory` (or any name you prefer).
> This repository will be the secure vault for your personal data.

### 2. One-Line Installation
Paste this into your terminal (Mac / Linux / Windows Git Bash / Termux):

```bash
curl -sSL https://raw.githubusercontent.com/lanstar128/AI_memory_siklls/main/install.sh | bash
```

**What the script does:**
1. Checks your environment dependencies (Git, SSH, Hub CLI).
2. Clones the official skills to `~/.ai-memory/skills`.
3. Guides you to clone your private data repo to `~/.ai-memory/data`.
4. Sets up the **Smart Aggregation** directory at `~/.ai-memory/current_skills`.
5. Links everything to your installed AI tools automatically.

---

## 🛠 Usage Guide

Once installed, simply talk to your AI assistant naturally:

### Essential Commands

| Command | Skill | Description |
|---------|-------|-------------|
| **"Sync Memory"** | `memory-sync` | Push local changes to your private cloud |
| **"Pull Memory"** | `memory-sync` | Get latest updates from other devices |
| **"Update Skills"** | `memory-sync` | Upgrade system code from official repo |
| **"Archive Chat"** | `conversation-archive` | Save current context to long-term memory |
| **"Recall [topic]"** | `memory-recall` | Search through your entire knowledge base |

### Directory Structure

Your second brain lives in `~/.ai-memory`:

```text
~/.ai-memory/
├── 📂 skills/          # [Public] Official skill logic (This Repo)
├── 📂 data/            # [Private] Your Secure Data Vault
│   ├── 📂 conversations/ # Chat history archives
│   ├── 📂 knowledge/     # Distilled knowledge base
│   └── 📂 skills/        # (Optional) Your private, custom skills
├── 📂 current_skills/  # [Auto] The "Active Brain" (Public + Private)
└── 📂 models/          # Local Embedding models cache
```

---

## 🤝 Contributing

We believe in the power of community! If you've built a cool skill (e.g., "Web Scraper", "Todo Manager"), please share it!

1. Fork this repository
2. Create your skill in `skills/your-skill-name`
3. Write a `SKILL.md`
4. Submit a Pull Request

---

## 📜 License

MIT License © 2024 [Lanstar128](https://github.com/lanstar128)
