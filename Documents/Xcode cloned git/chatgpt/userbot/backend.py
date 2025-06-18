import json
import sys
from dataclasses import dataclass, asdict
from typing import List, Optional
import os
from pathlib import Path

# Optional Telethon import
try:
    from telethon.sync import TelegramClient
    from telethon.errors.rpcerrorlist import AuthKeyUnregisteredError
    TELETHON_AVAILABLE = True
except ImportError:
    TELETHON_AVAILABLE = False

# Optional YAML config
try:
    import yaml  # type: ignore
except ImportError:
    yaml = None  # type: ignore


@dataclass
class Chat:
    id: int
    title: str


@dataclass
class Message:
    id: int
    chat_id: int
    text: str
    date: str


def get_demo_chats() -> List[Chat]:
    return [Chat(id=1, title="Demo chat"), Chat(id=2, title="Project")]


def get_demo_messages(chat_id: int) -> List[Message]:
    sample = {
        1: [
            Message(id=1, chat_id=1, text="Hello from Python backend!", date="2024-04-01T10:00:00Z"),
            Message(id=2, chat_id=1, text="This is a demo message", date="2024-04-01T10:05:00Z")
        ],
        2: [
            Message(id=3, chat_id=2, text="Discuss roadmap", date="2024-04-03"),
            Message(id=4, chat_id=2, text="Sprint planning", date="2024-04-04")
        ],
    }
    return sample.get(chat_id, [])


def handle_command(cmd: dict):
    name = cmd.get("cmd")
    client = _get_client()
    if name == "get_chats":
        if client:
            dialogs = client.get_dialogs()
            chats = [{"id": d.id, "title": d.name} for d in dialogs]
        else:
            chats = [asdict(c) for c in get_demo_chats()]
        print(json.dumps(chats), flush=True)
    elif name == "get_messages":
        chat_id = int(cmd.get("chat_id", 0))
        if client:
            msgs = client.get_messages(chat_id, limit=50)
            messages = [
                {
                    "id": m.id,
                    "chat_id": chat_id,
                    "text": m.message,
                    "date": m.date.isoformat() if m.date else ""
                } for m in reversed(msgs)
            ]
        else:
            messages = [asdict(m) for m in get_demo_messages(chat_id)]
        print(json.dumps(messages), flush=True)
    elif name == "send_message":
        if client:
            chat_id = cmd.get("chat_id")
            text = cmd.get("text")
            sent = client.send_message(chat_id, text)
            message = {
                "id": sent.id,
                "chat_id": chat_id,
                "text": text,
                "date": sent.date.isoformat() if sent.date else ""
            }
        else:
            message = {
                "id": 999,
                "chat_id": cmd.get("chat_id"),
                "text": cmd.get("text"),
            }
        print(json.dumps(message), flush=True)
    elif name == "send_file":
        chat_id = int(cmd.get("chat_id", 0))
        file_path = cmd.get("file_path")
        if client and file_path:
            sent = client.send_file(chat_id, file=file_path)
            message = {
                "id": sent.id,
                "chat_id": chat_id,
                "text": file_path,
                "date": sent.date.isoformat() if sent.date else ""
            }
        else:
            message = {"error": "send_file failed"}
        print(json.dumps(message), flush=True)
    elif name == "update_config":
        if yaml is None:
            print(json.dumps({"error": "PyYAML not installed"}), flush=True)
            return
        cfg = _load_config()
        cfg.update(cmd.get("values", {}))
        cfg_path = Path(__file__).with_name("config.yaml")
        try:
            cfg_path.write_text(yaml.safe_dump(cfg))
            print(json.dumps({"status": "ok"}), flush=True)
        except Exception as exc:
            print(json.dumps({"error": str(exc)}), flush=True)
    else:
        print(json.dumps({"error": f"Unknown command {name}"}), flush=True)


def main_loop():
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            cmd = json.loads(line)
        except json.JSONDecodeError:
            print(json.dumps({"error": "Invalid JSON"}), flush=True)
            continue
        handle_command(cmd)


if __name__ == "__main__":
    main_loop()

# ---------------------------------------------------------------------------
# Helpers for real Telegram client
# ---------------------------------------------------------------------------

_client: Optional["TelegramClient"] = None


def _load_config() -> dict:
    """Load config.yaml next to this file (if exists)."""
    cfg_path = Path(__file__).with_name("config.yaml")
    if cfg_path.exists() and yaml is not None:
        try:
            return yaml.safe_load(cfg_path.read_text()) or {}
        except Exception:
            return {}
    return {}


def _get_client() -> Optional["TelegramClient"]:
    global _client
    if _client is not None:
        return _client

    if not TELETHON_AVAILABLE:
        return None

    cfg = _load_config()
    api_id = int(cfg.get("api_id", 0)) or int(os.getenv("TG_API_ID", 0))
    api_hash = cfg.get("api_hash") or os.getenv("TG_API_HASH", "")
    bot_token = cfg.get("bot_token") or os.getenv("TG_BOT_TOKEN", "")

    if not api_id or not api_hash:
        return None

    session_path = str(Path(__file__).with_name("userbot.session"))

    if bot_token:
        # Bot session
        client = TelegramClient(session_path, api_id, api_hash)
        client.start(bot_token=bot_token)
    else:
        # User session – must have been logged in earlier
        client = TelegramClient(session_path, api_id, api_hash)
        try:
            client.connect()
            if not client.is_user_authorized():
                return None  # not logged in yet
        except AuthKeyUnregisteredError:
            return None
    _client = client
    return _client


def interactive_login(api_id: int, api_hash: str) -> None:
    """Run Telethon interactive login in terminal, stores session next to backend.py"""
    if not TELETHON_AVAILABLE:
        print("Telethon not installed", file=sys.stderr)
        return
    session_path = str(Path(__file__).with_name("userbot.session"))
    client = TelegramClient(session_path, api_id, api_hash)
    print("[userbot] Starting interactive login…", file=sys.stderr)
    client.start()
    print("[userbot] Login successful, session saved at", session_path, file=sys.stderr) 