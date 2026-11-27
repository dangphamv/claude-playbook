#!/usr/bin/env bash
# Case scaffold (must live in the case dir): delegates to the shared scaffold one level up.
exec bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/scaffold-common.sh"
