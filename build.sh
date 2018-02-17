#!/bin/bash

CUR_DATE=$(date)

#Help function
function HELP {
  echo "

Help documentation for NanoPi Platform Builder
Basic usage: ./build.sh -d nanopineo
Switches:
  -d        Create platform for Specific Devices. Supported device names:
              nanopineo2, nanopineo (nanopineo-air)
  -v <vers> Version must be a dot separated number. Example 1.102
  -p <dir>  Optionally patch the builder. <dir> should contain a tree of
            files you want to replace within the build tree. Experts only.
  -u <yes>  Build u-boot
  -k <yse>  Build kernel
"
  exit 1
}

#Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#
if [ "$NUMARGS" -eq 0 ]; then
  HELP
fi

while getopts d:u:k:v:p:h FLAG; do
  case $FLAG in
    d)
      DEVICE=$OPTARG
      ;;
    h)  #show help
      HELP
      ;;
    u)  
      BUILD_UBOOT=$OPTARG
      ;;
    k)  
      BUILD_KERNEL=$OPTARG
      ;;
    v)
      VERSION=$OPTARG
      ;;
    p)
      PATCH=$OPTARG
      ;;
    /?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      HELP
      ;;
  esac
done

#check target device
if [ "$DEVICE" = nanopineo2 ]; then
  echo "Start building Volumio for NanoPi-NEO2"
  KERNEL_VERSION="4.14.0-h5"
  KERNEL_ARCH="arm64"
  KERNEL_DEFCONFIG="sunxi_arm64_defconfig"
  KERNEL_CROSS_COMPILE="aarch64-linux-gnu-"
  KERNEL_IMAGE_FILE="Image"
elif [ "$DEVICE" = nanopineo ]; then
  echo "Start building Volumio for NanoPi-NEO (Air)"
  KERNEL_VERSION="4.14.0-h3"
  KERNEL_ARCH="arm"
  KERNEL_DEFCONFIG="sunxi_defconfig"
  KERNEL_CROSS_COMPILE="arm-linux-"
  KERNEL_IMAGE_FILE="zImage"
else
  echo "Unexpected target device '$DEVICE' - aborting."
  exit
fi

#prepare volumio build
if [ -d "Volumio-Build" ]; then
  echo "Volumio-Build folder exist"
else
  echo "Clone Volumio-Build from github"
  git clone https://github.com/volumio/Build Volumio-Build
fi

echo "Build platform files for "$DEVICE
if [ -d "./Volumio-Build/platform-$DEVICE/$DEVICE" ]; then
  echo "Platform folder exist"

  if ls ./Volumio-Build/platform-$DEVICE/$DEVICE/u-boot/u-boot* 1> /dev/null 2>&1; then
    echo "U-boot file do exist"
  else
    echo "U-boot file don't exist"
    BUILD_UBOOT="yes"
  fi

  if ls ./Volumio-Build/platform-$DEVICE/$DEVICE/boot/*mage 1> /dev/null 2>&1; then
    echo "Kernel image file do exist"
  else
    echo "Kernel image file don't exist"
    BUILD_KERNEL="yes"
  fi
else
  echo "Platform folder don't exist"
  mkdir -p ./Volumio-Build/platform-$DEVICE/$DEVICE
  cp -r ./nanopineo/$DEVICE/* ./Volumio-Build/platform-$DEVICE/$DEVICE/

  if [ ! -d "./Volumio-Build/platform-$DEVICE/$DEVICE/boot" ]; then
    mkdir ./Volumio-Build/platform-$DEVICE/$DEVICE/boot
  fi
  if [ ! -d "./Volumio-Build/platform-$DEVICE/$DEVICE/u-boot" ]; then
    mkdir ./Volumio-Build/platform-$DEVICE/$DEVICE/u-boot
  fi
  if [ ! -d "./Volumio-Build/platform-$DEVICE/$DEVICE/lib" ]; then
    mkdir ./Volumio-Build/platform-$DEVICE/$DEVICE/lib
  fi
  if [ ! -d "./Volumio-Build/platform-$DEVICE/$DEVICE/etc" ]; then
    mkdir ./Volumio-Build/platform-$DEVICE/$DEVICE/etc
  fi
  if [ ! -d "./Volumio-Build/platform-$DEVICE/$DEVICE/usr" ]; then
    mkdir ./Volumio-Build/platform-$DEVICE/$DEVICE/usr
  fi
  if [ ! -d "./Volumio-Build/platform-$DEVICE/$DEVICE/var" ]; then
    mkdir ./Volumio-Build/platform-$DEVICE/$DEVICE/var
  fi

  BUILD_UBOOT="yes"
  BUILD_KERNEL="yes"
fi

if [ -d "./Volumio-Build/platform-$DEVICE/$DEVICE/lib/firmware" ]; then
  echo "Firmware folder do exist"
else
  echo "Extract firmware files"
  tar xfJ ./nanopineo/firmware.tar.xz -C ./Volumio-Build/platform-$DEVICE/$DEVICE/lib/
fi

if [ "$BUILD_UBOOT" == "yes" ]; then
if [ -d "nanopineo/u-boot" ]; then
  echo "u-boot folder exist"
else
  echo "Creating u-boot folder"
  cd nanopineo
  git clone https://github.com/friendlyarm/u-boot.git
  cd u-boot
  git checkout sunxi-v2017.x
  cd ../..
fi

cd nanopineo/u-boot
case "$DEVICE" in
  nanopineo2) echo 'Building NanoPi-NEO2 u-boot files'
    make nanopi_h5_defconfig CROSS_COMPILE=$KERNEL_CROSS_COMPILE
    make CROSS_COMPILE=$KERNEL_CROSS_COMPILE
    cp ./spl/sunxi-spl.bin ../../Volumio-Build/platform-$DEVICE/$DEVICE/u-boot/
    cp ./u-boot.itb ../../Volumio-Build/platform-$DEVICE/$DEVICE/u-boot/
    ;;
  nanopineo) echo 'Building NanoPi-NEO (Air) u-boot files'
    make nanopi_h3_defconfig ARCH=arm CROSS_COMPILE=$KERNEL_CROSS_COMPILE
    make ARCH=arm CROSS_COMPILE=$KERNEL_CROSS_COMPILE
    cp ./u-boot-sunxi-with-spl.bin ../../Volumio-Build/platform-$DEVICE/$DEVICE/u-boot/
    ;;
esac
cd ../..
fi

if [ "$BUILD_KERNEL" == "yes" ]; then
if [ -d "nanopineo/kernel" ]; then
  echo "Kernel folder exist"
else
  echo "Creating kernel folder"
  cd nanopineo
  git clone https://github.com/nikkov/friendlyarm-linux kernel
  cd kernel
  git checkout sunxi-4.x.y
  cd ../..
fi

cd nanopineo/kernel
touch .scmversion

case "$DEVICE" in
  nanopineo2) echo 'Building NanoPi-NEO2 kernel files'
    ;;
  nanopineo) echo 'Building NanoPi-NEO (Air) kernel files'
    ;;
esac

#make clean
make $KERNEL_DEFCONFIG ARCH=$KERNEL_ARCH CROSS_COMPILE=$KERNEL_CROSS_COMPILE
make $KERNEL_IMAGE_FILE dtbs modules ARCH=$KERNEL_ARCH CROSS_COMPILE=$KERNEL_CROSS_COMPILE
make modules_install ARCH=$KERNEL_ARCH CROSS_COMPILE=$KERNEL_CROSS_COMPILE INSTALL_MOD_PATH=output
cp ./arch/$KERNEL_ARCH/boot/$KERNEL_IMAGE_FILE ../../Volumio-Build/platform-$DEVICE/$DEVICE/boot/
cp ./.config ../../Volumio-Build/platform-$DEVICE/$DEVICE/boot/config-${KERNEL_VERSION}
rm -r ../../Volumio-Build/platform-$DEVICE/$DEVICE/lib/*
cp -r ./output/lib/* ../../Volumio-Build/platform-$DEVICE/$DEVICE/lib/
rm ../../Volumio-Build/platform-$DEVICE/$DEVICE/boot/$KERNEL_IMAGE_FILE.version
echo "${KERNEL_VERSION}-${CUR_DATE}" >> "../../Volumio-Build/platform-$DEVICE/$DEVICE/boot/$KERNEL_IMAGE_FILE.version"

case "$DEVICE" in
  nanopineo2) echo 'Copy NanoPi-NEO2 dtb files'
    cp ./arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dtb ../../Volumio-Build/platform-$DEVICE/$DEVICE/boot/sun50i-h5-nanopi-neo2-slave.dtb
    cp ./arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dtb ../../Volumio-Build/platform-$DEVICE/$DEVICE/boot/sun50i-h5-nanopi-neo2.dtb
    fdtput --type s ../../Volumio-Build/platform-$DEVICE/$DEVICE/boot/sun50i-h5-nanopi-neo2.dtb i2s0 clock-source "pll"
    ;;
  nanopineo) echo 'Copy NanoPi-NEO (Air) dtb files'
    cp ./arch/arm/boot/dts/sun8i-h3-nanopi-neo.dtb ../../Volumio-Build/platform-$DEVICE/$DEVICE/boot/sun8i-h3-nanopi-neo-slave.dtb
    cp ./arch/arm/boot/dts/sun8i-h3-nanopi-neo.dtb ../../Volumio-Build/platform-$DEVICE/$DEVICE/boot/sun8i-h3-nanopi-neo.dtb
    fdtput --type s ../../Volumio-Build/platform-$DEVICE/$DEVICE/boot/sun8i-h3-nanopi-neo.dtb i2s0 clock-source "pll"

    cp ./arch/arm/boot/dts/sun8i-h3-nanopi-neo-air.dtb ../../Volumio-Build/platform-$DEVICE/$DEVICE/boot/sun8i-h3-nanopi-neo-air-slave.dtb
    cp ./arch/arm/boot/dts/sun8i-h3-nanopi-neo-air.dtb ../../Volumio-Build/platform-$DEVICE/$DEVICE/boot/sun8i-h3-nanopi-neo-air.dtb
    fdtput --type s ../../Volumio-Build/platform-$DEVICE/$DEVICE/boot/sun8i-h3-nanopi-neo-air.dtb i2s0 clock-source "pll"
    ;;
esac

cd ../..
mkimage -C none -A arm -T script -d ./Volumio-Build/platform-$DEVICE/$DEVICE/boot/boot.cmd ./Volumio-Build/platform-$DEVICE/$DEVICE/boot/boot.scr
fi

cd Volumio-Build
echo 'Building Volumio image'
cd Volumio-Build
/bin/bash ./build.sh -v "$VERSION" -p "$PATCH" -b armv7 -d $DEVICE
cd ..
