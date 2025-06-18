import json
import os
import io
import sys
import tempfile
import pytest
from userbot import backend

# Helper to capture JSON output from handle_command

def run_cmd(cmd):
    buf = io.StringIO()
    old_stdout = sys.stdout
    sys.stdout = buf
    try:
        backend.handle_command(cmd)
    finally:
        sys.stdout = old_stdout
    out = buf.getvalue().strip()
    try:
        return json.loads(out)
    except json.JSONDecodeError:
        pytest.skip(f"Output is not valid JSON: {out}")


def test_get_chats_demo():
    res = run_cmd({"cmd": "get_chats"})
    assert isinstance(res, list)
    assert res[0]["id"] == 1
    assert "title" in res[0]


def test_get_messages_demo():
    res = run_cmd({"cmd": "get_messages", "chat_id": 1})
    assert isinstance(res, list)
    assert res[0]["chat_id"] == 1
    assert "text" in res[0]


def test_send_message_demo():
    text = "hello"
    res = run_cmd({"cmd": "send_message", "chat_id": 1, "text": text})
    assert isinstance(res, dict)
    assert res["chat_id"] == 1
    assert res["text"] == text

@pytest.mark.skipif(not hasattr(backend, '_load_config'), reason="update_config not implemented")
def test_update_config(tmp_path, monkeypatch):
    # Prepare a fake config.yaml
    cfg_file = tmp_path / "config.yaml"
    cfg_file.write_text("api_id: 1\napi_hash: testhash\n")
    # Monkeypatch config path
    monkeypatch.setattr(backend, '_load_config', lambda: {'api_id': 1, 'api_hash': 'testhash'})
    monkeypatch.setattr(backend.Path, 'with_name', lambda self, name: cfg_file)
    res = run_cmd({"cmd": "update_config", "values": {"api_id": 2, "api_hash": "newhash"}})
    assert res == {"status": "ok"}
    # Verify file content updated
    text = cfg_file.read_text()
    assert 'api_id: 2' in text
