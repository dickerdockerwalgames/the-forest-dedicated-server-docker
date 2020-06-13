#!/bin/bash -x

# Enforce starting as root
if [ "0" -ne "`id -u`" ]; then
	echo "Please start container as root."
	exit 1
fi

# Export environment variables which are needed later
export THE_FOREST_APPLICATION_EXE="TheForestDedicatedServer.exe"
export THE_FOREST_DIR="/theforest_ds"
export STEAM_APPID
export STEAM_LOGIN
export THE_FOREST_CFG_DIR="/theforest_ds_config"
export THE_FOREST_SAVE_DIR="${THE_FOREST_CFG_DIR}/saves"

export WINEPREFIX="/theforest_ds_wineprefix"
export WINEDEBUG=""

export UPDATE_DEBIAN
export UPDATE_DEDICATED_SERVER

export DEBIAN_FRONTEND=noninteractive


# Check whether the IP in the config file is valid (This is done in /start_server.sh)

# Make sure steam user can access the server config to alter it.
chown -R steam:steam /theforest_ds_config/

# Create the default X11 unix socket directory to allow xvfb-run to work as user steam.
mkdir -p /tmp/.X11-unix/
chown root:root /tmp/.X11-unix/
chmod 1777 /tmp/.X11-unix/


# Update debian if image is outdated
if [ "1" -eq "${UPDATE_DEBIAN}" ]; then
	apt-get update && \
	apt-get -y dist-upgrade && \
	apt-get clean autoclean && \
	apt-get autoremove -y && \
	rm -rf /var/lib/apt/lists/*
fi


# Drop root privilege and use user steam to execute command
if [ "0" -eq "`id -u`" ]; then
	set -- gosu steam "$@"
fi

# Finally execute the Docker CMD
#exec "$@"
$@
