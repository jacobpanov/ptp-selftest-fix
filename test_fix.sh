#!/bin/bash

# Test script to verify the PTP selftest fix
# This script demonstrates the compilation issue and the fix

echo "=== PTP Selftest Fix Verification ==="
echo

# Check if required files exist
if [ ! -f "testptp.c" ]; then
    echo "Error: testptp.c not found"
    echo "Please copy testptp.c from the kernel source to this directory"
    exit 1
fi

if [ ! -d "../kernel-headers/include" ]; then
    echo "Error: kernel-headers not found"
    echo "Please ensure kernel headers are available"
    exit 1
fi

echo "1. Testing compilation WITHOUT kernel headers (should fail):"
echo "   gcc testptp.c -o testptp_fail"
if gcc testptp.c -o testptp_fail 2>&1; then
    echo "   ❌ Unexpected success - compilation should have failed"
else
    echo "   ✅ Expected failure - missing PTP_MASK_* definitions"
fi
echo

echo "2. Testing compilation WITH kernel headers (should succeed):"
echo "   gcc -I../kernel-headers/include testptp.c -o testptp_success"
if gcc -I../kernel-headers/include testptp.c -o testptp_success 2>&1; then
    echo "   ✅ Success - compilation with kernel headers works"
else
    echo "   ❌ Unexpected failure - fix should work"
fi
echo

echo "3. Verifying required definitions exist in kernel headers:"
if grep -q "PTP_MASK_CLEAR_ALL\|PTP_MASK_EN_SINGLE" ../kernel-headers/include/linux/ptp_clock.h; then
    echo "   ✅ Required PTP_MASK_* definitions found in kernel headers"
    echo "   Lines:"
    grep -n "PTP_MASK_CLEAR_ALL\|PTP_MASK_EN_SINGLE" ../kernel-headers/include/linux/ptp_clock.h
else
    echo "   ❌ Required PTP_MASK_* definitions not found"
fi
echo

echo "=== Test Complete ==="
echo "The fix adds kernel headers to CFLAGS to resolve compilation issues"
echo "introduced in kernel v6.7 with commit c5a445b"
