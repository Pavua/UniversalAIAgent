"""Userbot CLI entrypoint.
Usage: python3 -m userbot [--api-id ID] [--api-hash HASH] [--version]

Currently, api-id/api-hash are optional and only printed for debugging.
The command then starts the JSON stdin/stdout gateway defined in backend.main_loop()."""

import argparse
import importlib
import sys
import os
try:
    import openai
except ImportError:
    openai = None


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(prog="userbot", add_help=True)
    parser.add_argument("--api-id", type=int, default=0, help="Telegram API ID")
    parser.add_argument("--api-hash", type=str, default="", help="Telegram API Hash")
    parser.add_argument("--version", action="store_true", help="Print version and exit")
    parser.add_argument("--login", action="store_true", help="Interactive Telegram login and exit")
    parser.add_argument("--chat", action="store_true", help="Interactive chat with OpenAI and exit")
    parser.add_argument("--export-path", type=str, help="Path to Telegram export directory or JSON file", default="")
    parser.add_argument("--dataset-out", type=str, help="Output JSONL dataset path", default="dataset.jsonl")
    return parser.parse_args()


def chat_loop():
    if openai is None:
        print("OpenAI library not installed. Please install with 'pip install openai'", file=sys.stderr)
        sys.exit(1)
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("Missing OPENAI_API_KEY environment variable", file=sys.stderr)
        sys.exit(1)
    openai.api_key = api_key
    print("Starting OpenAI chat. Type your message and press Enter. Ctrl+C to exit.", file=sys.stderr)
    while True:
        try:
            prompt = input("> ")
        except (EOFError, KeyboardInterrupt):
            print("\nExiting chat.", file=sys.stderr)
            break
        if not prompt:
            continue
        try:
            response = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=[{"role": "user", "content": prompt}],
                stream=True
            )
            for chunk in response:
                delta = chunk.choices[0].delta
                content = delta.get("content")
                if content:
                    print(content, end="", flush=True)
            print()
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)


def main() -> None:
    args = parse_args()
    if args.chat:
        chat_loop()
        sys.exit(0)

    if args.version:
        print("userbot 0.1.0")
        sys.exit(0)

    # If user wants login flow
    if args.login:
        backend = importlib.import_module("userbot.backend")
        backend.interactive_login(args.api_id, args.api_hash)
        sys.exit(0)

    # New: convert Telegram export to dataset
    if args.export_path:
        from userbot.dataset import telegram_export_to_jsonl
        count = telegram_export_to_jsonl(args.export_path, args.dataset_out)
        print(f"Converted {count} messages to {args.dataset_out}")
        sys.exit(0)

    # Lazy import to avoid circular
    backend = importlib.import_module("userbot.backend")
    print("[userbot] Starting backend main loop", file=sys.stderr)
    backend.main_loop()


if __name__ == "__main__":
    main() 