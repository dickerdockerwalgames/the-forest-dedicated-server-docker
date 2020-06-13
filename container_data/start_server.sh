#!/bin/bash

# Update the forest for windows if the executable cannot be found (1st start) or the update flag is set (UPDATE_DEDICATED_SERVER)
if [ ! -f "${THE_FOREST_DIR}/${THE_FOREST_APPLICATION_EXE}" ] || [ "${UPDATE_DEDICATED_SERVER}" -eq "1" ]; then
	/usr/games/steamcmd +login "${STEAM_LOGIN}" +@sSteamCmdForcePlatformType windows +force_install_dir "${THE_FOREST_DIR}" +app_update "${STEAM_APPID}" validate +quit
	ERRNO="$?"
	if [ "0" -ne "$ERRNO" ]; then
		echo "Error: $ERRNO"
		exit $ERRNO
	fi
fi

# Make sure the server config has the right ip address
if [ -f "${THE_FOREST_CFG_DIR}/config.cfg" ]; then
	if [ -w "${THE_FOREST_CFG_DIR}/config.cfg" ]; then

		CUR_IP="`hostname -I | cut -d' ' -f1`"
		NEW_IP_IN_FILE="`perl -nle 'print $2 if /^(\s*serverIP\s+)(\Q'"${CUR_IP}"'\E)/' "${THE_FOREST_CFG_DIR}/config.cfg"`"

		# If current container ip is not in file, set it.
		if [ -z "$OLD_IP" ]; then
			perl -i -ple 's/^(\s*serverIP\s+)(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/${1}'"${CUR_IP}"'/' "${THE_FOREST_CFG_DIR}/config.cfg"
			echo "Updated the forest config file (set correct container IP address)!"
		fi
	fi
fi

cd "${THE_FOREST_DIR}"

export DISPLAY=":0"

# We need tty permission to write to stderr
exec xvfb-run --server-num=0 --error-file="/dev/stderr" --server-args='-screen 0 640x480x24:32 -nolisten tcp -nolisten unix' \
	bash -x -c "export DISPLAY=\":0\"; wine64 \"`winepath -w "${THE_FOREST_DIR}/${THE_FOREST_APPLICATION_EXE}" 2>/dev/null`\" -batchmode -nographics -nosteamclient -savefolderpath \"`winepath -w "${THE_FOREST_SAVE_DIR}" 2>/dev/null`\" -configfilepath \"`winepath -w "${THE_FOREST_CFG_DIR}/config.cfg" 2>/dev/null`\" | perl -pe 's/RenderTexture\.Create failed: format unsupported - 2\..*[\r\n]+//'"
