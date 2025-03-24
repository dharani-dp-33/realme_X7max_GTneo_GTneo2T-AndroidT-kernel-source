# Realme X7 Max Kernel Source

Custom kernel with auto-fix system for Realme X7 Max/GT Neo devices

## Features
- Auto-error fixing via GitHub Actions
- MediaTek Dimensity 1200 optimizations
- Stock ROM compatibility

## Build Instructions
```bash
git clone https://github.com/dharani-dp-33/realme_X7max_GTneo_GTneo2T-AndroidT-kernel-source
make defconfig
make -j$(nproc)
