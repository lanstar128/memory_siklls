# 🧠 AI Memory System (AMS)

<div align="center">

**Build a persistent, cross-platform, privacy-first "Second Brain" for your AI assistants.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

[English](./README.md) | [简体中文](./README_zh-CN.md)

</div>

**AI Memory System (AMS)** is a **Global Memory Layer** designed specifically for terminal AI tools like **Antigravity, Claude Code, Gemini CLI, Open Interpreter, and iFlow**.

### 🚨 The Pain: Fragmented AI Memory
When using local AI development tools across different environments (Terminal / IDE), developers face a critical problem:
- **Memory Silos**: What you teach your AI on your MacBook is lost when you switch to Windows or Android Termux.
- **Experience Drain**: You solve a complex error once, but have to debug it from scratch in a new environment because the "memory" is trapped locally.
- **Context Loss**: Your AI doesn't know your coding style or architectural decisions discussed on another device last week.

**AMS is built to solve this.** It gives all your AI tools a shared "Brain", ensuring that your knowledge, experience, and context are synchronized instantly across all your devices.

---

## 🌟 Core Value

- **🧠 Global Memory**
  - **Break Device Silos**: Whether you develop on Mac Terminal, Windows Git Bash, or Android Termux, your AI accesses the same accumulated knowledge base.
  - **Solve Once, Reuse Everywhere**: When AI helps you fix a tricky bug, that experience is crystallized. The next time you encounter it on *any* device, AI recalls the solution instantly.

- **💎 Experience Crystallization**
  - **Knowledge Distillation**: Turns scattered chat logs into structured **Knowledge Crystals** (Markdown/Snippets), not just raw history.
  - **Continuous Growth**: Your AI assistant grows with you, understanding your project context better every day, instead of resetting to a blank slate.

- **🛡️ Private & Secure Control**
  - **Code (Public) + Data (Private)**: All memory data lives in your own private GitHub repository.
  - **Data Sovereignty**: You have full control. No proprietary cloud lock-in. Secure, transparent, and yours.

- **⚡️ Seamless Cross-Device Relay**
  - **Workflow Handoff**: Start a logic design on your office workstation, "Sync Memory", and continue the conversation seamlessly on your phone via Termux on the way home.
  - **Smart Aggregation**: Automatically merges official skill updates with your unique private configurations.

---

## 🔧 How It Works

It's not magic; it's a smart composition of existing technologies. We leverage the **Agent Skills Standard (File-based Definitions)** natively supported by modern terminal AI tools:

```mermaid
graph LR
    A[Gemini/Claude] -->|Load| B[SKILL.md (Standard Definition)]
    B -->|Execute| C[Local Scripts (Bash/Python)]
    C -->|Read/Write| D[Local File System (~/.ai-memory)]
    D -->|Git Push| E[Private GitHub Repo]
    E -->|Git Pull| F[Other Devices]
```

1.  **Universal Skill Standard (`SKILL.md`)**:
    We use the `SKILL.md` format (YAML Frontmatter + Markdown) natively supported by Google Antigravity and Anthropic Claude Code.
    *This is NOT the complex MCP protocol*, but a lighter, more universal **file-level context injection**. Simply by placing these files in specific directories (e.g., `~/.gemini/skills`), the AI automatically gains "memory capabilities".

2.  **Git as Backend**:
    We use Git's robust version control as a "distributed database," naturally handling sync, conflicts, and history.

3.  **Local-First**:
    All memory operations are essentially file I/O on your local machine—fast, private, and independent of 3rd-party APIs.

**Simply put**: We used the most universal standard (`SKILL.md`) to teach AI how to use the most mature tool (Git) to manage its own "notebook."

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

We welcome contributions that extend the core capabilities of the Memory System! This is **not** just another script collection; it's a foundational layer for AI cognition.

Key areas where we need your help:
- **Memory Adaptors**: Support for Vector DBs (Pinecone, Milvus) or Graph DBs (Neo4j).
- **Retrieval Strategies**: Implement Advanced RAG, Hybrid Search, or Re-ranking algorithms.
- **Tool Integrations**: Plugins for VS Code, JetBrains, or browser extensions.
- **Privacy Core**: Enhancements to local encryption and zero-knowledge sync protocols.

Fork -> Branch -> PR. Let's build the future of AI memory together.

## 🔮 Roadmap

### 5.1 Memory Hierarchy
Moving beyond flat "long-term" storage to a structured lifecycle system:
- **Conversation Memory**: Ephemeral, discarded after session exit.
- **Session Memory**: Task-scoped, archived or discarded upon completion.
- **User Memory**: Long-term, stores user preferences and habits.
- **Skill Memory**: Permanent, reusable knowledge and capabilities.

### 5.2 Dynamic Forgetting
Simulating human memory to keep the system efficient:
- **Relevance Decay**: Reduce retrieval weight for memories not accessed for a long time.
- **Memory Pruning**: New `memory-prune` skill to clean up expired or low-value content.

### 5.3 Enhanced Retrieval
- **Graph Structures**: Track relationships between memories to build a knowledge graph.
- **Time Awareness**: Prioritize recent memories during retrieval ("Recency Bias").
- **Multi-modal Support**: Embedding support for images and code snippets.

### 5.4 User Preferences
Explicit user profiling system:
- **Coding Style**: e.g., "Prefers TypeScript", "Concise comments".
- **Work Habits**: e.g., "Active hours 9-12 PM", "Prefers Dark Mode".

---

## 📜 License

MIT License © 2024 [Lanstar128](https://github.com/lanstar128)
