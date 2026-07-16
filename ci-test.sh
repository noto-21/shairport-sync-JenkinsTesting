#!/bin/bash
set -e

echo "=== 1. Installing Essential Dependencies ==="
apt-get update && apt-get install -y --no-install-recommends \
    build-essential autoconf automake libtool pkg-config \
    libssl-dev libasound2-dev libpopt-dev libconfig-dev \
    avahi-daemon libavahi-client-dev \
    python3 python3-pip python3-venv

echo "=== 2. Isolating Build Environment ==="
mkdir -p /native-build
cp -r /build/. /native-build
cd /native-build
cat verify-gitversion | tr -d '\r' > /tmp/verify-gitversion
cat /tmp/verify-gitversion > verify-gitversion

echo "=== 3. Injecting Intentional Software Fault ==="
# Inject a Null Pointer Dereference right after the main function begins in shairport.c
sed -i 's/int main(int argc, char \*\*argv) {/int main(int argc, char **argv) {\n    int *crash_ptr = 0;\n    *crash_ptr = 1;/g' shairport.c

echo "=== 4. Compiling Shairport Sync ==="
autoreconf -fi
./configure --with-ssl=openssl --with-alsa --with-avahi
make -j "$(nproc)"

echo "=== 5. Setting up Python AI Environment ==="
# Use a virtual environment to safely install requests
python3 -m venv /venv
/venv/bin/pip install requests

echo "=== 6. Executing Application & Capturing Telemetry ==="
LOG_PATH="/native-build/crash_telemetry.log"

# Run the faulty binary directly. We expect a Segmentation Fault, so we disable set -e temporarily.
set +e
./shairport-sync > "$LOG_PATH" 2>&1
EXIT_CODE=$?
set -e

echo "Application exited with code: $EXIT_CODE"
echo "=== RAW TERMINAL OUTPUT ==="
cat "$LOG_PATH"
echo "==========================="

echo "=== 7. Invoking ESOps LLaMA Engine ==="
/venv/bin/python /native-build/esops_analyzer.py "$LOG_PATH" "Shairport Sync (Linux User-Space)"
