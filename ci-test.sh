#!/bin/bash
set -e

echo "=== 1. Installing Essential Dependencies ==="
# We only install modern, standard packages. No deprecated crypto or niche audio layers.
apt-get update && apt-get install -y --no-install-recommends \
    build-essential autoconf automake libtool pkg-config \
    libssl-dev libasound2-dev libpopt-dev libconfig-dev \
    avahi-daemon libavahi-client-dev

echo "=== 2. Isolating Build Environment ==="
# Keep our robust Windows-Docker bypass strategy
mkdir -p /native-build
cp -r /build/. /native-build
cd /native-build

# Sanitize line endings for the gitversion script so the build can check the release version
cat verify-gitversion | tr -d '\r' > /tmp/verify-gitversion
cat /tmp/verify-gitversion > verify-gitversion

echo "=== 3. Running Targeted Smoke Test ==="
# Generate the configure script from configure.ac
autoreconf -fi

# Configure with a robust, modern flag combination (OpenSSL crypto + ALSA audio + Avahi mDNS)
./configure --with-ssl=openssl --with-alsa --with-avahi

# Compile the application using all available CPU cores
echo "Compiling Shairport Sync..."
make -j $(nproc)

echo "========================================="
# If it reaches this point without throwing an error, the build is fully sound!
echo "   SUCCESS: Simple Smoke Test Passed!    "
echo "========================================="
