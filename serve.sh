#!/usr/bin/env sh
# Local preview: serves this folder on http://localhost:8000
cd "$(dirname "$0")" && python3 -m http.server 8000
