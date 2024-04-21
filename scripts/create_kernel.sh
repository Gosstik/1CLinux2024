#!/bin/bash

# --all --- full install from the very beginning
# --deps --- install dependencies
# --boot --- only kernel
# --vroot --- init file and directories
# --busybox --- prereq for initramfs
# --initramfs --- initramfs

################################################################################

# Parse args.

ALL=""
DEPS=""
BOOT=""
VROOT=""
BUSYBOX=""
INITRAMFS=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --all)
      ALL="1"
      shift 1 ;;
    --deps)
      DEPS="1"
      shift 1 ;;
    --boot)
      BOOT="1"
      shift 1 ;;
    --vroot)
      VROOT="1"
      shift 1 ;;
    --busybox)
      BUSYBOX="1"
      shift 1 ;;
    --initramfs)
      INITRAMFS="1"
      shift 1 ;;
    *)
      echo "Unexpected argument: '$1'"
      exit 1
  esac
done

KERNEL_DIR="${PWD}"

################################################################################

# Dependencies.

if [ -n "${ALL}" ] || [ -n "${DEPS}" ]; then
  sudo apt-get update && sudo apt-get -y upgrade
  sudo apt-get -y install build-essential \
                          libncurses-dev \
                          bison \
                          flex \
                          libssl-dev \
                          libelf-dev \
                          libelf-dev \
                          bc \
                          cpu-checker \
                          qemu-system-x86 \
                          aria2
#else
#  echo "skipping deps stage"
fi

################################################################################

# Boot.

#echo -e "-----------------------"

LINUX_DIR="linux-6.7.4"
LINUX_TAR_FILE="${LINUX_DIR}.tar.xz"
LINUX_TAR_LINK="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.7.4.tar.xz"

if [ -n "${ALL}" ] || [ -n "${BOOT}" ]; then
  echo "[###] starting boot stage..."
  cd "${KERNEL_DIR}" || echo -e "unable to cd '${KERNEL_DIR}'\npwd = $PWD" && exit 10

  if [ -f "${LINUX_TAR_FILE}" ]; then
    echo "[###] '${LINUX_TAR_FILE}' is already installed, skip installation"
  else
    wget -O "${LINUX_TAR_FILE}" "${LINUX_TAR_LINK}"
  fi

  if [ -d "${LINUX_DIR}" ]; then
    echo "[###] removing existing linux directory"
    rm -rf "${LINUX_DIR}"
  fi
  tar -xf "${LINUX_TAR_FILE}"

  echo "[###] make defconfig"
  cd "${LINUX_DIR}" || echo -e "unable to 'cd ${LINUX_DIR}'\npwd = $PWD" && exit 10
  make defconfig

  echo "[###] make all"
  make -j$(($(nproc) + 1)) all

  echo "[###] make install"
  mkdir -p ../boot
  INSTALL_PATH=../boot make install

  echo "[###] list boot content"
  cd ../boot || echo -e "unable to 'cd ../boot'\npwd = $PWD" && exit 10
  ls

  echo "[###] boot stage finished"
#else
#  echo "[###] skipping boot stage"
fi

################################################################################

# Vroot.

#echo -e "-----------------------"

VROOT_DIR="vroot"
INIT_FILE="init"
read -r -d '' INIT_CONTENT<<EOF || echo "ok" > /dev/null
#!/bin/sh

mount -t devtmpfs devtmpfs /dev
mount -t tmpfs tmpfs /tmp
mount -t proc proc /proc
mount -t sysfs sysfs /sys

echo 0 > /proc/sys/kernel/printk

exec setsid sh -c 'exec sh </dev/ttyS0 >/dev/ttyS0 2>&1'
EOF

echo "INIT_CONTENT = ${INIT_CONTENT}"

if [ -n "${ALL}" ] || [ -n "${BOOT}" ]; then
  echo "[###] starting vroot stage..."
  cd "${KERNEL_DIR}" || echo -e "unable to cd '${KERNEL_DIR}'\npwd = $PWD" && exit 10

  if [ -d "${VROOT_DIR}" ]; then
    echo "[###] removing existing vroot directory"
    rm -rf "${VROOT_DIR}"
  fi

  mkdir "${VROOT_DIR}"
  cd "${VROOT_DIR}" || echo -e "unable to cd '${VROOT_DIR}'\npwd = $PWD" && exit 10
  mkdir sys bin lib dev root tmp proc

  echo "[###] creating init file"
  touch "${INIT_FILE}"
  chmod +x "${INIT_FILE}"
  echo "${INIT_CONTENT}" > "${INIT_FILE}"

  echo "[###] vroot stage finished"
#else
#  echo "[###] skipping vroot stage"
fi

################################################################################

# Busybox.

#echo -e "-----------------------"

BUSYBOX_DIR="busybox-1.36.1"
BUSYBOX_TAR_FILE="${BUSYBOX_DIR}.tar.bz2"
BUSYBOX_TAR_LINK="https://busybox.net/downloads/busybox-1.36.1.tar.bz2"

if [ -n "${ALL}" ] || [ -n "${BOOT}" ]; then
  echo "[###] starting busybox stage..."
  cd "${KERNEL_DIR}" || echo -e "unable to cd '${KERNEL_DIR}'\npwd = $PWD" && exit 10

  if [ -f "${BUSYBOX_TAR_FILE}" ]; then
    echo "[###] '${BUSYBOX_TAR_FILE}' is already installed, skip installation"
  else
    wget -O "${BUSYBOX_TAR_FILE}" "${BUSYBOX_TAR_LINK}"
  fi

  if [ -d "${BUSYBOX_DIR}" ]; then
    echo "[###] removing existing busybox directory"
    rm -rf "${BUSYBOX_DIR}"
  fi
  tar -xf "${BUSYBOX_TAR_FILE}"

  echo "[###] make defconfig"
  cd "${BUSYBOX_DIR}" || echo -e "unable to 'cd ${BUSYBOX_DIR}'\npwd = $PWD" && exit 10
  make defconfig

  echo "[###] make menuconfig"
  make menuconfig

  echo "[###] make all"
  make -j$(($(nproc) + 1)) all

  echo "[###] make install"
  mkdir ../busybox
  INSTALL_PATH=../boot make install

  echo "[###] install binaries to vroot"
  cd ../"${VROOT_DIR}" || echo -e "unable to 'cd ../${VROOT_DIR}'\npwd = $PWD" && exit 10
  ../busybox/bin/busybox --install ./bin

  echo "[###] busybox stage finished"
#else
#  echo "[###] skipping busybox stage"
fi

################################################################################

# Initramfs.

#echo -e "-----------------------"

INITRAMFS_NAME="initramfs"

if [ -n "${ALL}" ] || [ -n "${BOOT}" ]; then
  echo "[###] starting initramfs stage..."
  cd "${KERNEL_DIR}" || echo -e "unable to cd '${KERNEL_DIR}'\npwd = $PWD" && exit 10

  if [ -f "${INITRAMFS_NAME}" ]; then
    echo "[###] removing old initramfs"
    rm -f "${INITRAMFS_NAME}"
  fi

  cd "./${VROOT_DIR}" || echo -e "unable to cd './${VROOT_DIR}'\npwd = $PWD" && exit 10

  echo "[###] installing initramfs"
  find . | cpio -ov --format=newc | gzip -9 > ../initramfs

  echo "[###] initramfs stage finished"
#else
#  echo "[###] skipping initramfs stage"
fi
