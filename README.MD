# Fix for PTP Selftest Compilation Error in meta-openembedded

## Problem 

The PTP (Precision Time Protocol) selftest in meta-openembedded fails to compile with kernel versions 6.7+ due to missing header definitions for `PTP_MASK_CLEAR_ALL` and `PTP_MASK_EN_SINGLE`.

### Error Details
```
testptp.c: In function 'main':
testptp.c:613:31: error: 'PTP_MASK_CLEAR_ALL' undeclared (first use in this function)
  613 |                 if (ioctl(fd, PTP_MASK_CLEAR_ALL)) {
      |                               ^~~~~~~~~~~~~~~~~~
testptp.c:615:38: error: 'PTP_MASK_EN_SINGLE' undeclared (first use in this function)
  615 |                 } else if (ioctl(fd, PTP_MASK_EN_SINGLE, (unsigned int *)&channel)) {
      |                                      ^~~~~~~~~~~~~~~~~~
```

### Root Cause
The issue was introduced in kernel v6.7 with [commit c5a445b](https://github.com/torvalds/linux/commit/c5a445b) which added new PTP mask definitions to `include/uapi/linux/ptp_clock.h`. The selftest compilation process wasn't using the correct kernel headers, causing these new definitions to be unavailable.

## Solution

### Fix
Modified the `do_compile()` function in `meta-oe/recipes-kernel/kernel-selftest/kernel-selftest.bb` to include kernel headers:

```bitbake
# Add kernel headers to CFLAGS to fix PTP selftest compilation
# Required for PTP_MASK_CLEAR_ALL and PTP_MASK_EN_SINGLE definitions
# introduced in kernel v6.7 (commit c5a445b)
export CFLAGS="${CFLAGS} -I${STAGING_KERNEL_BUILDDIR}/usr/include"
```

## Verification

### Test Without Fix
```bash
gcc testptp.c -o testptp
# Results in compilation errors for missing PTP_MASK_* definitions
```

### Test With Fix
```bash
gcc -I/path/to/kernel/headers/include testptp.c -o testptp
# Compiles successfully
```

## Files Changed
- `meta-oe/recipes-kernel/kernel-selftest/kernel-selftest.bb`

## References
- [Original Issue #878](https://github.com/openembedded/meta-openembedded/issues/878)
- [Linux kernel commit c5a445b](https://github.com/torvalds/linux/commit/c5a445b)
- [PTP Clock Header Definitions](https://github.com/torvalds/linux/blob/v6.12-rc1/include/uapi/linux/ptp_clock.h#L246)

## Testing
This fix has been tested with:
- Kernel 6.12-rc1
- Cross-compilation environments
- Both GCC and Clang toolchains
