from __future__ import annotations

"""Dataset utilities for preparing fine-tuning data.

Currently supports converting Telegram Desktop JSON exports into JSONL
format where each line is a JSON object with fields:
  chat_id, message_id, date, sender, text

This simple format can later be transformed into instruction/response
pairs for LoRA/ChatML training.
"""

import json
from pathlib import Path
from typing import Iterable, List, Any

__all__ = [
    "telegram_export_to_jsonl",
]


# ---------------------------------------------------------------------------
# Telegram export helpers
# ---------------------------------------------------------------------------

def _extract_text(fragment: Any) -> str:
    """Return plain text from a Telegram message "text" field.

    The field can be:
    1) a plain string
    2) a list with strings and/or dicts {"type": "plain", "text": "..."}
    3) a dict with type "plain"
    """
    if isinstance(fragment, str):
        return fragment
    if isinstance(fragment, dict):
        if fragment.get("type") == "plain":
            return str(fragment.get("text", ""))
        # For other fragment types (link, mention, emoji) we keep raw text
        return str(fragment.get("text", ""))
    if isinstance(fragment, list):
        return "".join(_extract_text(f) for f in fragment)
    return ""


def _parse_chat_json(chat_json: dict) -> Iterable[dict]:
    """Yield normalized messages from a single chat json dict."""
    chat_id = chat_json.get("id")
    messages = chat_json.get("messages", [])
    for msg in messages:
        if msg.get("type") != "message":
            continue  # ignore service messages etc.
        text_raw = msg.get("text")
        text = _extract_text(text_raw)
        if not text.strip():
            continue  # skip empty/attachment-only msgs
        yield {
            "chat_id": chat_id,
            "message_id": msg.get("id"),
            "date": msg.get("date"),
            "sender": msg.get("from") or msg.get("actor"),
            "text": text,
        }


def _find_export_files(path: Path) -> List[Path]:
    """Return list of *.json files to parse given a path to export root or file."""
    if path.is_file():
        return [path]

    # Look for common Telegram Desktop export structure: top level has
    # result.json + /chats/*.json
    json_files: List[Path] = []
    for p in path.rglob("*.json"):
        # Skip small meta files like stickers.json etc. Keep messages.json style
        if not p.name.startswith("messages") and p.name != "result.json":
            continue
        # Exclude files that are not chat message dumps (e.g., profile.json)
        json_files.append(p)
    return json_files


def telegram_export_to_jsonl(input_path: str | Path, output_path: str | Path = "dataset.jsonl") -> int:
    """Convert Telegram export to newline-delimited JSON-L (".jsonl") file.

    Returns number of messages written.
    """
    in_path = Path(input_path).expanduser().resolve()
    out_path = Path(output_path).expanduser().resolve()

    files = _find_export_files(in_path)
    if not files:
        raise FileNotFoundError(f"No Telegram *.json export files found in {in_path}")

    count = 0
    with out_path.open("w", encoding="utf-8") as fout:
        for f in files:
            with f.open("r", encoding="utf-8") as fp:
                try:
                    chat_json = json.load(fp)
                except json.JSONDecodeError:
                    continue  # skip invalid
            for msg in _parse_chat_json(chat_json):
                fout.write(json.dumps(msg, ensure_ascii=False) + "\n")
                count += 1
    return count 