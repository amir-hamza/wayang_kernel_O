#!/bin/bash
kernel_dir=$PWD
export V="v1.6"
export CONFIG_FILE="mido_defconfig"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=vicatz
export KBUILD_BUILD_HOST=Dalang
export TOOL_CHAIN_PATH="/home/vicatz/toolchains/linaro/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-"
export CLANG_TCHAIN="/home/vicatz/toolchains/clang/DragonTC-8.0.0-20180830/bin/clang"
export CLANG_VERSION="$(${CLANG_TCHAIN} --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export LD_LIBRARY_PATH="${TOOL_CHAIN_PATH}/../lib"
export PATH=$PATH:${TOOL_CHAIN_PATH}
export builddir="${kernel_dir}/mateng"
#export modules_dir="zip/system/lib/modules"
export ZIPPER_DIR="${kernel_dir}/zip"
export ZIP_NAME="wayang™${V}-Los_Aosp.zip"
export ZIMAGE DIR="arch/arm64/boot"
export IMAGE="arch/arm64/boot/Image.gz";
JOBS="-j8"
cd $kernel_dir
make clean && make mrproper

make_a_fucking_defconfig() {
	make $CONFIG_FILE
}

compile() {
	PATH=${BIN_FOLDER}:${PATH} make \
	O=${out_dir} \
	CC="${CLANG_TCHAIN}" \
	CLANG_TRIPLE=aarch64-linux-gnu- \
	CROSS_COMPILE=${TOOL_CHAIN_PATH} \
    KBUILD_COMPILER_STRING="${CLANG_VERSION}" \
	HOSTCC="${CLANG_TCHAIN}" \
    $JOBS
}

zipit () {
    if [[ ! -f "${IMAGE}" ]]; then
        echo -e "Build failed :P";
        exit 1;
    else
        echo -e "Build Succesful!";
    fi
    echo "**** Copying zImage ****"
    cp arch/arm64/boot/Image.gz ${ZIPPER_DIR}/tools/
    echo "**** Copying treble & non .dtb ****"
	cp arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-mido-nontreble.dtb ${ZIPPER_DIR}/nontreble/
	cp arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-mido-treble.dtb ${ZIPPER_DIR}/treble/

    cd ${ZIPPER_DIR}/
    zip -r9 ${ZIP_NAME} * -x README ${ZIP_NAME}
    rm -rf ${kernel_dir}/mateng/${ZIP_NAME}
    mv ${ZIPPER_DIR}/${ZIP_NAME} ${kernel_dir}/mateng/${ZIP_NAME}
}

make_a_fucking_defconfig
compile
zipit
cd ${kernel_dir}
