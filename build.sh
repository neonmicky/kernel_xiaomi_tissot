#!/bin/bash
echo "Cloning dependencies"
git clone --depth=1 -b xr https://github.com/neonmicky/kernel_xiaomi_tissot kernel
cd kernel
git clone --depth=1 -b master https://github.com/kdrag0n/proton-clang clang
git clone https://github.com/neonmicky/AnyKernel3 -b tissot --depth=1 AnyKernel
echo "Done"
KERNEL_DIR=$(pwd)
IMAGE="${KERNEL_DIR}/out/arch/arm64/boot/Image.gz-dtb"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
TANGGAL=$(date +"%Y%m%d-%H")
export PATH="$(pwd)/clang/bin:$PATH"
export KBUILD_COMPILER_STRING="$($kernel/clang/bin/clang --version | head -n 1 | perl -pe 's/\((?:http|git).*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')"
export ARCH=arm64

# Compile plox
function compile() {
    make -j$(nproc) O=out ARCH=arm64 tissot_defconfig
    make -j$(nproc) O=out \
                    ARCH=arm64 \
                      CC=clang \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \

    if ! [ -a "$IMAGE" ]; then
        exit 1
        echo "There are some issues"
    fi
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}
# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 Perf+Kernel-${TANGGAL}.zip *
    curl --upload-file Perf+Kernel-${TANGGAL}.zip https://free.keep.sh
}
compile
zipping
