# Warzone-TerminalSpawn
Script for automatically spawning yakuake terminals with dbus 

## How to use this script
Make the script executable:
```
chmod +x ./WarZone.sh
```
***
Run it like this:
```
./WarZone.sh '-vecho vertical spawn' '-hecho horizontal spawn' '-k'
```
***
## Arguments:  
The following arguments are recognized by this script
```
--help
```
Displays some help to get started without reading this document

```
-k
```
Kills the first (empty) window which get's created after you spawn a new yakuake session.
You can specify this argument if you don't want to keep an open window for typing your own stuff and just want to run things

```
-h[<Command>]
```
or
```
-v[<Command>]
```
Spawns a new window with a horizontal or vertical split. The Command is optional. Without typing anything after it will spawn a new, empty, terminal window.
