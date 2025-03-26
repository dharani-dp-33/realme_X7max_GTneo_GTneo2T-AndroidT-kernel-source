#!/bin/bash
set -e

echo "=== Starting Kernel Build Automation ==="

# ------------------------------------------------------------------------------
# Step 1: Clean and Prepare Build Environment
# ------------------------------------------------------------------------------
echo "Cleaning previous build artifacts..."
make mrproper

# ------------------------------------------------------------------------------
# Step 2: Apply Custom Kernel Configuration
# ------------------------------------------------------------------------------
# Use your custom defconfig file (ensure it includes desired options)
# If you have a file (e.g., config/custom_defconfig), copy it as .config.
if [ -f config/custom_defconfig ]; then
  echo "Applying custom defconfig..."
  cp config/custom_defconfig .config
else
  echo "No custom defconfig found. Using default configuration..."
  make defconfig
fi

# Force disable module signature checks and enable force loading.
echo "Disabling module signature checks..."
sed -i 's/^CONFIG_MODULE_SIG=.*/CONFIG_MODULE_SIG=n/' .config || echo "CONFIG_MODULE_SIG=n" >> .config
sed -i 's/^# CONFIG_MODULE_FORCE_LOAD is not set/CONFIG_MODULE_FORCE_LOAD=y/' .config || echo "CONFIG_MODULE_FORCE_LOAD=y" >> .config

# Verify config changes
grep "CONFIG_MODULE_SIG" .config
grep "CONFIG_MODULE_FORCE_LOAD" .config

# ------------------------------------------------------------------------------
# Step 3: Integrate MemKernel Module
# ------------------------------------------------------------------------------
echo "Integrating MemKernel module..."
# Remove any existing memkernel directory
rm -rf drivers/misc/memkernel
mkdir -p drivers/misc/memkernel
# Assuming the MemKernel source is located in ../MemKernel/driver/
if [ -d ../MemKernel/driver/ ]; then
  cp -r ../MemKernel/driver/* drivers/misc/memkernel/
  echo "MemKernel integrated from ../MemKernel/driver/"
else
  echo "Warning: MemKernel source not found in ../MemKernel/driver/ - please adjust the path."
fi

# ------------------------------------------------------------------------------
# Step 4: Remove Proprietary Dependencies & Unwanted Code
# ------------------------------------------------------------------------------
echo "Removing proprietary dependencies and unwanted modules..."
# Example: Remove all references to 'sched_assist' across the source.
# Adjust the file search pattern as needed.
find . -type f -exec sed -i '/sched_assist/d' {} \;

# If there are specific files to remove or patch, add commands here.
# For instance, to remove a proprietary dependency file:
# rm -f path/to/proprietary_dependency.c

# ------------------------------------------------------------------------------
# Step 5: Build the Kernel
# ------------------------------------------------------------------------------
echo "Building the kernel..."
make -j$(nproc)

echo "=== Kernel Build Complete ==="
