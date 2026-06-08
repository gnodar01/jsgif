#!/usr/bin/env bash
# Build the jsgif bookmarklet inside a podman container holding the toolchain.
#
# Builds the image if it's missing, makes sure the podman machine is up (macOS),
# then runs make-bookmarklet and writes the result to bookmarklet.txt (or to the
# path given as $1, or to stdout if that's "-").
set -euo pipefail

cd "$(dirname "$0")"

IMAGE=jsgif-build
OUT="${1:-bookmarklet.txt}"

# On macOS podman runs in a VM; start it if it isn't already up.
if ! podman info >/dev/null 2>&1; then
  echo "Starting podman machine..." >&2
  podman machine start
fi

# Build the image only if we don't already have it.
if ! podman image exists "$IMAGE"; then
  echo "Building image $IMAGE..." >&2
  podman build -t "$IMAGE" -f Containerfile .
fi

if [ "$OUT" = "-" ]; then
  podman run --rm -v "$PWD":/src:Z "$IMAGE"
else
  podman run --rm -v "$PWD":/src:Z "$IMAGE" > "$OUT"
  echo "Wrote $OUT ($(wc -c < "$OUT" | tr -d ' ') bytes)" >&2
fi
