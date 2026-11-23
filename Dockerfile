# OpenChamber for Railway: https://github.com/aalfath/openchamber-railway-template
# Upstream publishes no Docker image. This builds the official npm release of OpenChamber
# (@openchamber/web, the same build as the GitHub release tag) and the OpenCode CLI, both
# pinned in package.json and bun.lock (with integrity hashes), on the Bun image upstream's
# own Dockerfile uses, pinned by version and digest. Bump all of them together (see CHANGELOG.md).
FROM oven/bun:1.4.4@sha256:1d22548f177f4ff38e0c15baa3c2c46c6c2060ba2d1bc573bb4720b407548f1d

# Tools the agent and the built-in terminal need: git, SSH for git remotes, Python and Node.js.
RUN apt-get update && apt-get install -y --no-install-recommends \
      bash bzip2 ca-certificates curl git jq less nodejs npm openssh-client procps python3 tini \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package.json bun.lock ./
# Install exactly what bun.lock pins. OpenCode ships one binary per CPU variant; keep the
# "baseline" x64 build (runs on any x86-64 host, no AVX2 needed) and drop the other
# variants (about 730 MB).
RUN bun install --frozen-lockfile --production \
  && rm node_modules/@opencode/cli/bin/opencode.exe \
  && cp node_modules/@opencode/cli-linux-x64-baseline/bin/opencode node_modules/@opencode/cli/bin/opencode.exe \
  && rm -r node_modules/@opencode/cli-linux-* \
  && ln -s /app/node_modules/.bin/opencode /usr/local/bin/opencode \
  && printf '#!/bin/sh\nexec bun /app/node_modules/@openchamber/web/bin/cli.js "$@"\n' > /usr/local/bin/openchamber \
  && chmod 755 /usr/local/bin/openchamber \
  && opencode --version && rm -r /root/.bun/install/cache

# Everything OpenChamber and OpenCode store (settings, sessions, provider credentials, SSH key)
# lives under HOME, and your code lives in /data/workspaces. Mount one Railway volume at /data.
ENV HOME=/data/home \
    OPENCHAMBER_OPENCODE_CWD=/data/workspaces \
    OPENCODE_DISABLE_AUTOUPDATE=1 \
    NODE_ENV=production \
    LANG=C.UTF-8 \
    PORT=3000

COPY start.sh /app/start.sh
EXPOSE 3000
ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/bin/sh", "/app/start.sh"]
