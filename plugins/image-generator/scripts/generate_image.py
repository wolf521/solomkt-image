#!/usr/bin/env python3
"""
Claude Code Image Generation Plugin
====================================
Generates images via the GenerateImage API.

API Endpoint: https://prompt-manager-uat.issmart.com.cn/app-system-prompt/api/GenerateImage

Usage:
    python generate_image.py setup --api-key <YOUR_API_KEY>
    python generate_image.py generate --prompt "your image description"
    python generate_image.py config --show
"""

import sys
import os
import json
import argparse
import urllib.request
import urllib.error
from pathlib import Path
from typing import Optional

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
API_URL = "https://prompt-manager-uat.issmart.com.cn/app-system-prompt/api/GenerateImage"
CONFIG_DIR_NAME = ".claude-image-plugin"
CONFIG_FILE_NAME = "config.json"


# ---------------------------------------------------------------------------
# Config helpers
# ---------------------------------------------------------------------------
def get_config_dir() -> Path:
    """Return the plugin config directory path (~/.claude-image-plugin)."""
    return Path.home() / CONFIG_DIR_NAME


def get_config_path() -> Path:
    """Return the full path to the config JSON file."""
    return get_config_dir() / CONFIG_FILE_NAME


def load_config() -> dict:
    """Load configuration from disk. Returns {} if file does not exist."""
    config_path = get_config_path()
    if config_path.exists():
        try:
            with open(config_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except (json.JSONDecodeError, OSError) as exc:
            print(json.dumps({
                "success": False,
                "error": f"Failed to read config file: {exc}"
            }))
            sys.exit(1)
    return {}


def save_config(config: dict) -> Path:
    """Persist config to disk. Creates directory if needed."""
    config_dir = get_config_dir()
    config_dir.mkdir(parents=True, exist_ok=True)
    config_path = config_dir / CONFIG_FILE_NAME
    with open(config_path, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
    return config_path


def resolve_api_key(cli_key: Optional[str] = None) -> Optional[str]:
    """
    Resolve API key in priority order:
      1. CLI argument (--api-key)
      2. Config file
      3. IMAGE_API_KEY environment variable
    """
    if cli_key:
        return cli_key.strip()

    config = load_config()
    if config.get("api_key"):
        return config["api_key"].strip()

    env_key = os.environ.get("IMAGE_API_KEY", "").strip()
    return env_key if env_key else None


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------
def cmd_setup(args) -> None:
    """
    Interactive or CLI setup for the API key.
    Usage:
        python generate_image.py setup --api-key <KEY>
        python generate_image.py setup          # interactive prompt
    """
    api_key = args.api_key

    if not api_key:
        print("=" * 60)
        print("  Claude Code Image Generation Plugin - Initial Setup")
        print("=" * 60)
        print()
        print("Please enter your API Key to start using image generation.")
        print("You can obtain an API Key from your system administrator.")
        print()
        try:
            api_key = input("API Key: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nSetup cancelled.")
            sys.exit(0)

    if not api_key:
        print(json.dumps({
            "success": False,
            "error": "No API Key provided. Please run: python generate_image.py setup --api-key YOUR_KEY"
        }))
        sys.exit(1)

    config = load_config()
    config["api_key"] = api_key
    config_path = save_config(config)

    print(json.dumps({
        "success": True,
        "message": f"API Key saved successfully. Config stored at: {config_path}",
        "config_path": str(config_path)
    }, ensure_ascii=False))


def cmd_generate(args) -> None:
    """
    Call the GenerateImage API with the given prompt.
    Outputs JSON: {"success": true, "imageUrl": "..."} on success
               or {"success": false, "error": "..."} on failure
    """
    prompt = args.prompt
    if not prompt or not prompt.strip():
        print(json.dumps({
            "success": False,
            "error": "No prompt provided. Usage: python generate_image.py generate --prompt \"your description\""
        }))
        sys.exit(1)

    api_key = resolve_api_key()
    if not api_key:
        print(json.dumps({
            "success": False,
            "error": "API Key not configured. Please run setup first: python generate_image.py setup"
        }))
        sys.exit(1)

    # Build request
    request_body = json.dumps({"prompt": prompt.strip()}).encode("utf-8")
    req = urllib.request.Request(
        url=API_URL,
        data=request_body,
        headers={
            "Content-Type": "application/json",
            "X-API-Key": api_key,
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=120) as response:
            response_data = json.loads(response.read().decode("utf-8"))

        # Check for API-level error codes (some APIs return HTTP 200 with an error code in JSON)
        resp_code = response_data.get("code")
        if resp_code and int(resp_code) not in (200, 0):
            error_msg = response_data.get("message", "Unknown API error")
            hint = ""
            if int(resp_code) == 401:
                hint = " Please check your API Key (run: python generate_image.py setup)"
            print(json.dumps({
                "success": False,
                "error": f"API error {resp_code}: {error_msg}.{hint}",
            }, ensure_ascii=False))
            return

        image_url = response_data.get("imageUrl", "")
        if image_url:
            print(json.dumps({
                "success": True,
                "imageUrl": image_url,
            }, ensure_ascii=False))
        else:
            print(json.dumps({
                "success": False,
                "error": "API returned no imageUrl field.",
                "raw_response": response_data,
            }))

    except urllib.error.HTTPError as exc:
        try:
            error_body = exc.read().decode("utf-8")
        except Exception:
            error_body = str(exc)
        print(json.dumps({
            "success": False,
            "error": f"HTTP {exc.code}: {error_body}",
        }))

    except urllib.error.URLError as exc:
        print(json.dumps({
            "success": False,
            "error": f"Network error: {exc.reason}",
        }))

    except TimeoutError:
        print(json.dumps({
            "success": False,
            "error": "Request timed out (120s). Please try again.",
        }))

    except Exception as exc:
        print(json.dumps({
            "success": False,
            "error": f"Unexpected error: {type(exc).__name__}: {exc}",
        }))


def cmd_config(args) -> None:
    """Show or manage config. Currently only --show is supported."""
    config = load_config()
    if args.show:
        # Mask API key for security
        safe_config = dict(config)
        if safe_config.get("api_key"):
            key = safe_config["api_key"]
            if len(key) > 8:
                safe_config["api_key"] = key[:4] + "*" * (len(key) - 8) + key[-4:]
            else:
                safe_config["api_key"] = "****"
        safe_config["config_path"] = str(get_config_path())
        safe_config["config_exists"] = get_config_path().exists()
        print(json.dumps(safe_config, indent=2, ensure_ascii=False))


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(
        description="Claude Code Image Generation Plugin",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # First-time setup (interactive)
  python generate_image.py setup

  # First-time setup (non-interactive)
  python generate_image.py setup --api-key YOUR_API_KEY

  # Generate an image
  python generate_image.py generate --prompt "a sunset over mountains"

  # Show current config
  python generate_image.py config --show
        """,
    )
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # setup
    setup_parser = subparsers.add_parser("setup", help="Configure the API Key")
    setup_parser.add_argument("--api-key", help="API Key (will prompt interactively if omitted)")

    # generate
    generate_parser = subparsers.add_parser("generate", help="Generate an image from a prompt")
    generate_parser.add_argument("--prompt", required=True, help="Text description of the image to generate")

    # config
    config_parser = subparsers.add_parser("config", help="View / manage configuration")
    config_parser.add_argument("--show", action="store_true", help="Print current config (API key masked)")

    args = parser.parse_args()

    if args.command == "setup":
        cmd_setup(args)
    elif args.command == "generate":
        cmd_generate(args)
    elif args.command == "config":
        cmd_config(args)
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
