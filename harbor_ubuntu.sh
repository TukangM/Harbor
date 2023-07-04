#!/bin/sh

#############################
# Ubuntu Image Installation #
#############################

# Define the root directory to /home/container.
# We can only write in /home/container and /tmp in the container.
ROOTFS_DIR=/home/container

# Define the URL for the Ubuntu 22.04 base image.
BASE_IMAGE_URL="https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-amd64.tar.gz"

# Detect the machine architecture.
ARCH=$(uname -m)

# Check machine architecture to make sure it is supported.
# If not, we exit with a non-zero status code.
if [ "$ARCH" = "x86_64" ]; then
  ARCH_ALT=amd64
elif [ "$ARCH" = "aarch64" ]; then
  ARCH_ALT=arm64
else
  printf "Unsupported CPU architecture: ${ARCH}"
  exit 1
fi

# Download and extract the Ubuntu 22.04 base image if not already installed.
if [ ! -e $ROOTFS_DIR/.installed ]; then
    # Download the Ubuntu 22.04 base image.
    wget --no-hsts -O /tmp/ubuntu-base-22.04-base-amd64.tar.gz "$BASE_IMAGE_URL"
    # Extract the Ubuntu 22.04 base image.
    tar -xzf /tmp/ubuntu-base-22.04-base-amd64.tar.gz -C $ROOTFS_DIR
fi

#################################
# Package Installation & Setup #
#################################

# Customization for your own repository
# Add any additional steps required to configure your custom repository here.

# Update the package index and install desired packages.
chroot $ROOTFS_DIR apt-get update
chroot $ROOTFS_DIR apt-get install -y package1 package2 package3

# Finish up
if [ ! -e $ROOTFS_DIR/.installed ]; then
    # Create .installed to later check whether Ubuntu is installed.
    touch $ROOTFS_DIR/.installed
fi

# Print some useful information to the terminal before entering chroot.
clear && cat <<EOF

  ______          _ _       _     _____ _        _______ ______ _____  
 |  ____|        | (_)     (_)   / ____| |      |__   __|  ____|  __ \ 
 | |__ ___  _ __ | |_  __ _ _  | |    | |         | |  | |__  | |__) |
 |  __/ _ \| '_ \| | |/ _\` | | | |    | |         | |  |  __| |  ___|
 | | | (_) | | | | | | (_| | |_| |____| |____     | |  | |____| |    
 |_|  \___/|_| |_|_|_|\__,_|_(_)______|______|    |_|  |______|_|

Welcome to your customized Ubuntu 22.04 image!

Here are some useful commands to get you started:

- \`apt-get update\`: Update the package index.
- \`apt-get install [package]\`: Install a package.
- \`apt-get remove [package]\`: Remove a package.
- \`apt-get upgrade\`: Upgrade installed packages.
- \`apt-get autoremove\`: Remove unused packages.
- \`apt-cache search [keyword]\`: Search for a package.
- \`apt-cache show [package]\`: Show information about a package.

You can further customize this script by adding any additional configuration or package installation steps specific to your custom Ubuntu 22.04 base image.

Enjoy your customized Ubuntu 22.04 image!

EOF

###########################
# Start PRoot environment
###########################

$ROOTFS_DIR/usr/local/bin/proot \
--rootfs="${ROOTFS_DIR}" \
--link2symlink \
--kill-on-exit \
--root-id \
--cwd=/root \
--bind=/proc \
--bind=/dev \
--bind=/sys \
--bind=/tmp \
/bin/sh
