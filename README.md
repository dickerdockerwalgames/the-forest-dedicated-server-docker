# The Forest Dedicated Server Docker Image
Docker image for running a dedicated server of the indie game "The Forest".
This project contains the required files to build a Docker image for The Forest's windows-based dedicated server.
The image uses Debian Stable aka Buster since newer Wine versions (5+) yield several problems trying to run this game server.


## Getting started
In order to run this image, adapt these lines to your needs and run them:
```bash
docker run -it -d --rm --name theforest_ds_container \
    -p 27015:27015/tcp -p 27015:27015/udp \
    -p 27016:27016/tcp -p 27016:27016/udp \
    -p 8766:8766/tcp   -p 8766:8766/udp \
    -v "/absolute/host/dir/server-files":"/theforest_ds" \
    -v "/absolute/host/dir/config-save-dir":"/theforest_ds_config" \
    -v "/absolute/host/dir/wine-prefix":"/theforest_wineprefix" \
    theforest_ds:latest
```

The same command using named volumes:
```bash
docker run -it -d --rm --name theforest_ds_container \
    -p 27015:27015/tcp -p 27015:27015/udp \
    -p 27016:27016/tcp -p 27016:27016/udp \
    -p 8766:8766/tcp   -p 8766:8766/udp \
    -v "server-files":"/theforest_ds" \
    -v "/absolute/host/dir/config-save-dir":"/theforest_ds_config" \
    -v "wine-prefix":"/theforest_wineprefix" \
    theforest_ds:latest
```

The game server's executable files will be saved in "server-files".
The game server's wine environment will be saved in "wine-prefix".
The most relevant volume is "/theforest_ds_config" which stores the game configuration file and savegame files.



The `-it` part is needed to allow the container to properly access the stdout and stderr devices.
The ports are defined as follows:
- Steam services: 8766
- Game: 27015
- Game server query protocol: 27016
