#!/usr/bin/env python3
"""
Updates one service's entry in an environment manifest.

Usage:
    python3 scripts/update_manifest.py <environment> <service> <version> [digest]

This script is called as the final step of every dev build, every promotion,
and every release cut. It only ever touches the single service entry it is
given — every other entry in the file is left exactly as it was.
"""
import sys
import datetime
from pathlib import Path

import yaml

def main() -> None:
    if len(sys.argv) < 4:
        print("Usage: update_manifest.py <environment> <service> <version> [digest]")
        sys.exit(1)

    environment = sys.argv[1]
    service = sys.argv[2]
    version = sys.argv[3]
    digest = sys.argv[4] if len(sys.argv) > 4 else "simulated-digest-demo"

    manifest_path = Path("manifests") / f"{environment}.yaml"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)

    if manifest_path.exists():
        with manifest_path.open() as f:
            data = yaml.safe_load(f) or {}
    else:
        data = {}

    data.setdefault("environment", environment)
    data.setdefault("services", {})

    data["services"][service] = {
        "version": version,
        "digest": digest,
    }
    data["last_updated"] = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    with manifest_path.open("w") as f:
        yaml.dump(data, f, default_flow_style=False, sort_keys=False)

    print(f"Updated {manifest_path}: {service} -> {version}")

if __name__ == "__main__":
    main()
