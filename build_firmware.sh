#!/bin/bash

# 定义一些变量
IMAGEBUILDER_URL="https://downloads.immortalwrt.org/releases/24.10.2/targets/x86/64/immortalwrt-imagebuilder-24.10.2-x86-64.Linux-x86_64.tar.zst"
IMAGEBUILDER_DIR="immortalwrt-imagebuilder-24.10.2-x86-64.Linux-x86_64"
PLUGIN_LIST_FILE="plugins.list"
IPK_DIR="./softs" # 指定存放IPK文件的文件夹
ROOTFS_PARTSIZE=1024 # 设置 ROOTFS_PARTSIZE 为 1024MB

# 检查插件列表文件是否存在
if [ ! -f "$PLUGIN_LIST_FILE" ]; then
    echo "Error: Plugin list file '$PLUGIN_LIST_FILE' not found!"
    exit 1
fi

# 更新并安装必要的软件包
echo "Updating and installing necessary packages..."
sudo apt-get update
sudo apt-get install -y build-essential libncurses5-dev gawk git subversion libssl-dev gettext unzip zlib1g-dev file wget

# 下载镜像构建器
echo "Downloading ImageBuilder..."
wget $IMAGEBUILDER_URL -O imagebuilder.tar.zst

# 解压镜像构建器
echo "Extracting ImageBuilder..."
tar --use-compress-program=unzstd -xvf imagebuilder.tar.zst

# 确保脚本存放的文件夹拥有完全的可操作权限
echo "Setting full permissions for the current directory..."
sudo chmod -R 777 .

# 进入镜像构建器目录
cd $IMAGEBUILDER_DIR

# 创建自定义包目录并复制IPK文件
echo "Copying IPK files..."
mkdir -p packages
if [ -d "../$IPK_DIR" ]; then
    cp ../$IPK_DIR/*.ipk packages/
else
    echo "Warning: IPK directory '$IPK_DIR' not found, skipping..."
fi

# 读取插件列表文件内容
PLUGINS=$(tr '\n' ' ' < "../$PLUGIN_LIST_FILE")

# 更新包列表
echo "Updating package list..."
make update

# 设置 ROOTFS_PARTSIZE
echo "Setting ROOTFS_PARTSIZE to $ROOTFS_PARTSIZE MB..."
echo "CONFIG_TARGET_ROOTFS_PARTSIZE=$ROOTFS_PARTSIZE" >> .config

# 构建固件
echo "Building firmware..."
make image PROFILE=generic PACKAGES="$PLUGINS" FILES=files/

# 提示完成
echo "Firmware build completed!"
