import json
from pathlib import Path

from userbot.dataset import telegram_export_to_jsonl


def test_telegram_export_to_jsonl(tmp_path: Path):
    sample_export = {
        "id": 123,
        "name": "Sample Chat",
        "messages": [
            {"id": 1, "type": "message", "date": "2024-01-01T00:00:00", "from": "User", "text": "Hello"},
            {"id": 2, "type": "message", "date": "2024-01-01T00:01:00", "from": "Bot", "text": [
                {"type": "plain", "text": "World"}
            ]},
            {"id": 3, "type": "service", "action": "chat_photo_changed"},
        ]
    }

    export_file = tmp_path / "messages.json"
    export_file.write_text(json.dumps(sample_export))
    out_file = tmp_path / "dataset.jsonl"

    count = telegram_export_to_jsonl(export_file, out_file)

    assert count == 2
    lines = out_file.read_text().splitlines()
    assert len(lines) == 2
    records = [json.loads(l) for l in lines]
    assert records[0]["text"] == "Hello"
    assert records[1]["text"] == "World" 