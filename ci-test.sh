#!/bin/bash
set -e

echo "=== 1. Installing System Dependencies ==="
# We are installing all the obscure audio and SSL libraries the test script demands.
# Note: I omitted 'libpolarssl-dev' from the author's list because it has been 
# obsolete for years and will immediately break apt-get on modern Debian/Ubuntu.
apt-get update && apt-get install -y --no-install-recommends \
    build-essential autoconf automake libtool pkg-config git \
    ca-certificates \
    libmbedtls-dev libjack-dev libsndio-dev libao-dev \
    libpulse-dev libsndfile1-dev libavahi-compat-libdnssd-dev \
    libglib2.0-dev libmosquitto-dev libssl-dev libasound2-dev \
    libpopt-dev libconfig-dev

echo "=== 2. Building custom ALAC library ==="
# The test script strictly requires the ALAC library to be present.
# We clone it into /tmp, build it, and install it globally.
git clone https://github.com/mikebrady/alac.git /tmp/alac
cd /tmp/alac
autoreconf -fi
./configure
make -j $(nproc)
make install
ldconfig # Refresh the linker cache so Shairport can find libalac.so

echo "=== 3. Running Brute-Force Tests ==="
# Navigate back to your workspace root (adjust /build to your actual workspace path if needed)
cd /build

# Strip hidden Windows carriage returns (\r) from the build script
# This prevents the "required file not found" shebang crash
sed -i 's/\r$//' verify-gitversion

# The script MUST be executed from inside the test/ directory
cd tests
sh configure_test.sh || {
    echo "========================================================"
    echo "   TEST FAILED! Dumping /build/configure_test.log       "
    echo "========================================================"
    cat ../configure_test.log
    exit 1
}
