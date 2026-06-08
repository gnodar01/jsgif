# Build toolchain for the jsgif bookmarklet.
#
# make-bookmarklet needs: Ruby (the build script), a JRE (to run the vendored
# closure/compiler.jar), and yui-compressor. node is included too so the `h`
# CLI (GIF inspector) and the JS sanity checks work in the same image.
#
# Usage (from the repo root):
#   podman build -t jsgif-build -f Containerfile .
#   podman run --rm -v "$PWD":/src:Z jsgif-build > bookmarklet.txt
#
# The repo is bind-mounted at /src, so edits to html.js/gif.js/jsgif.css on the
# host are picked up without rebuilding the image.
FROM debian:stable-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ruby \
      default-jre-headless \
      yui-compressor \
      nodejs \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Default: build the bookmarklet and print it to stdout.
ENTRYPOINT ["ruby", "make-bookmarklet"]
