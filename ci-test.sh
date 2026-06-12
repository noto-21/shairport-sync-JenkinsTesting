#!/bin/bash
set -e

echo "=== 1. Installing System Dependencies ==="
# Force Git inside the container to handle line endings for Linux
git config --global core.autocrlf input

apt-get update && apt-get install -y --no-install-recommends \
    build-essential autoconf automake libtool pkg-config git \
    ca-certificates \
    libmbedtls-dev libjack-dev libsndio-dev libao-dev \
    libpulse-dev libsndfile1-dev libavahi-compat-libdnssd-dev \
    libglib2.0-dev libmosquitto-dev libssl-dev libasound2-dev \
    libpopt-dev libconfig-dev 

echo "=== 2. Building custom ALAC library ==="
git clone https://github.com/mikebrady/alac.git /tmp/alac
cd /tmp/alac
autoreconf -fi
./configure
make -j $(nproc)
make install
ldconfig

echo "=== 3. Running Brute-Force Tests ==="
cd /build 

# Safe Windows-to-Linux line sanitization using memory streams
# This reads the file, strips '\r', and outputs it without breaking NTFS file locks
cat verify-gitversion | tr -d '\r' > /tmp/verify-gitversion
cat /tmp/verify-gitversion > verify-gitversion

# The script MUST be executed from inside the tests/ directory
cd tests

# Run the test script. If it fails, dump the log file before exiting.
sh configure_test.sh || {
    echo "========================================================"
    echo "   TEST FAILED! Dumping /build/configure_test.log       "
    echo "========================================================"
    cat ../configure_test.log
    exit 1
}
