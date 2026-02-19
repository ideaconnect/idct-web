#!/bin/sh
set -e

REPO_URL="https://github.com/ideaconnect/idct-web.git"
REPO_DIR="/app"
BRANCH="main"
POLL_INTERVAL=60

# ---------------------------------------------------------------------------
# Clone or update the repository
# ---------------------------------------------------------------------------
if [ -d "${REPO_DIR}/.git" ]; then
    echo "[git] Repository already exists at ${REPO_DIR}, pulling latest ${BRANCH}..."
    cd "${REPO_DIR}"
    git fetch origin "${BRANCH}"
    git reset --hard "origin/${BRANCH}"
    echo "[git] Up to date: $(git rev-parse HEAD)"
else
    echo "[git] Cloning ${REPO_URL} into ${REPO_DIR}..."
    git clone --depth=1 --branch "${BRANCH}" "${REPO_URL}" "${REPO_DIR}"
    echo "[git] Cloned: $(git -C ${REPO_DIR} rev-parse HEAD)"
fi

# Verify the build folder exists
if [ ! -d "${REPO_DIR}/build" ]; then
    echo "WARNING: ${REPO_DIR}/build does not exist after clone. Caddy will serve an empty/missing directory." >&2
fi

# ---------------------------------------------------------------------------
# Signal handling — gracefully stop children on TERM / INT
# ---------------------------------------------------------------------------
_shutdown() {
    echo "[entrypoint] Received shutdown signal, stopping processes..."
    [ -n "${CADDY_PID}" ] && kill "${CADDY_PID}" 2>/dev/null
    [ -n "${POLLER_PID}" ] && kill "${POLLER_PID}" 2>/dev/null
    wait
    exit 0
}
trap _shutdown TERM INT

# ---------------------------------------------------------------------------
# Start Caddy
# ---------------------------------------------------------------------------
echo "[caddy] Starting Caddy..."
caddy run --config /etc/caddy/Caddyfile &
CADDY_PID=$!
echo "[caddy] PID ${CADDY_PID}"

# ---------------------------------------------------------------------------
# Background git poller — checks every POLL_INTERVAL seconds for new commits
# ---------------------------------------------------------------------------
_poll() {
    while true; do
        sleep "${POLL_INTERVAL}"
        cd "${REPO_DIR}"

        # Fetch silently; exit this iteration on network error
        if ! git fetch origin "${BRANCH}" 2>/dev/null; then
            echo "[git-poll] WARNING: fetch failed, will retry in ${POLL_INTERVAL}s"
            continue
        fi

        LOCAL=$(git rev-parse HEAD)
        REMOTE=$(git rev-parse "origin/${BRANCH}")

        if [ "${LOCAL}" != "${REMOTE}" ]; then
            echo "[git-poll] New commit detected: ${LOCAL} → ${REMOTE}. Updating..."
            git reset --hard "origin/${BRANCH}"
            echo "[git-poll] Updated to $(git rev-parse HEAD)"
        fi
    done
}

_poll &
POLLER_PID=$!
echo "[git-poll] Poller PID ${POLLER_PID}, interval ${POLL_INTERVAL}s"

# ---------------------------------------------------------------------------
# Wait for Caddy — if it exits, take the whole container down with it
# ---------------------------------------------------------------------------
wait "${CADDY_PID}"
echo "[entrypoint] Caddy exited, shutting down container."
kill "${POLLER_PID}" 2>/dev/null
exit 1
