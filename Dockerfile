FROM debian:stable-slim

ENV 	UPDATE_DEBIAN="1" \
	UPDATE_DEDICATED_SERVER="1" \
	STEAM_LOGIN="anonymous" \
	STEAM_APPID="556450"

# It's useless to try installing libsdl for steamcmd (but can run without it)
# wine32 for steam and wine64 for the server
RUN	export DEBIAN_FRONTEND=noninteractive && \
	echo steam steam/question select "I AGREE" | debconf-set-selections && \
	echo steam steam/license note '' | debconf-set-selections && \
	dpkg --add-architecture i386 && \
	sed -i 's/deb http:\/\/deb.debian.org\/debian stable main/deb http:\/\/deb.debian.org\/debian stable main non-free/' /etc/apt/sources.list && \
	apt-get update && \
	apt-get -y dist-upgrade && \
	apt-get -y -f install --no-install-recommends --no-install-suggests xvfb xauth screen steamcmd lib32gcc1 winbind ca-certificates wine wine64 wine32 gosu wget gnupg iproute2 nano && \
	apt-get clean autoclean && \
	apt-get autoremove -y && \
	rm -rf /var/lib/apt/lists/*	


# Add user steam and grant access to tty stdin, stdout, stderr
RUN useradd -m -U -G tty steam

# Redirect steam errors to stderr
RUN mkdir -p /home/steam/.steam/logs/ /home/steam/Steam/logs/ && \
	ln -s /dev/stderr /home/steam/.steam/logs/stderr.txt && \
	ln -s /dev/stderr /home/steam/Steam/logs/stderr.txt && \
	chown steam:steam /home/steam/.steam/ /home/steam/.steam/logs/ /home/steam/.steam/logs/stderr.txt && \
	chown steam:steam /home/steam/Steam/ /home/steam/Steam/logs/ /home/steam/Steam/logs/stderr.txt

# Windows game binaries, wineprefix, configuration directory, savegame directory
RUN mkdir /theforest_ds /theforest_ds_wineprefix /theforest_ds_config /theforest_ds_config/saves && \
	chown -R steam:steam /theforest_ds /theforest_ds_wineprefix /theforest_ds_config /theforest_ds_config/saves


# Copy start script
COPY "container_data/start_server.sh" "/start_server.sh"
# Copy entrypoint
COPY "container_data/entrypoint.sh" "/entrypoint.sh"
# Make them readable and executable
RUN chmod +555 /start_server.sh /entrypoint.sh

# Volume for saves and configuration
VOLUME ["/theforest_ds"]
VOLUME ["/theforest_ds_config"]
VOLUME ["/theforest_wineprefix"]


# Expose required ports
# Port for steam services: 8766
# Port for game: 27015
# Port for game server query protocol: 27016
EXPOSE 8766/tcp 8766/udp 27015/tcp 27015/udp 27016/tcp 27016/udp

# Setup script for environment
ENTRYPOINT ["bash", "/entrypoint.sh"]

# Update and start script
CMD ["bash", "/start_server.sh"]
