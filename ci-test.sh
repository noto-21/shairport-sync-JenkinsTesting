#!/bin/bash
# Exit immediately if any compilation step fails
set -e

echo "=== 1. Installing System Dependencies ==="
apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    libasound2-dev \
    libpopt-dev \
    libconfig-dev \
    libssl-dev \
    libavahi-client-dev \
    libsoxr-dev \
    libplist-dev \
    libsodium-dev \
    libgcrypt20-dev

echo "=== 2. Bootstrapping & Configuring ==="
autoreconf -fi
./configure --with-alsa --with-avahi --with-ssl=openssl --with-soxr

echo "=== 3. Compiling Application ==="
make -j$(nproc)

echo "=== 4. Executing Native Test Suite ==="
make check
