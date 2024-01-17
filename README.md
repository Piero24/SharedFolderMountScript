# SharedFolderMountScript

This is a simple script for people like me who have had problems with network shared folders connected when using [Sonarr](https://sonarr.tv), [Radarr](https://radarr.video) or client torrents like [Deluge](https://deluge-torrent.org) and [qBittorrent](https://www.qbittorrent.org).
In particular in my case these applications are run on docker containers managed by [CasaOS](https://www.casaos.io).

Unfortunately, however, there were several problems with folder permissions, as they all seem to belong to the root user.

My goal is to directly download files into the `/Download` folder of Synology connected to casaOS using Deluge and qBittorrent, and then move them with Sonarr and Radarr to the `/Movies` and `/TV` folders within the NAS, which are monitored by `Plex`. I've tried various solutions, such as:

- I attempted to use `PUID` set to `0`, which **works with Deluge but not with qBittorrent**. The latter requires `PUID` set to `1000`; otherwise, an error occurs, and the interface doesn't even open via the browser.
- I tried downloading the files to the internal HDD with both torrent clients in the `DATA/Downloads` folder, which didn't pose any problems. However, I'm experiencing slowness when subsequently transferring files to the NAS folder. I don't understand why it takes about 50 minutes for a 36 GB file.
- I also attempted to change the folder permissions, but I wasn't successful in changing the owner from root to the casaOS user.

So I decided to write this very basic and simple script that would allow me to correctly mount the shared folders on those of casaOS with user permissions in order to avoid all the problems indicated above.
This script starts automatically at system startup before the containers are started so as not to create problems when they start.

**NOTE:** Verify that `samba` is installed correctly.

## BASIC INFO
The script was designed to mount 3 different folders in three different places. One folder for downloads and 2 for different types of media but you can add and remove as many mounts as you want by making the necessary changes.

## PREPARE THE SCRIPT
Modify the script as follows:
- Change **IP-ADDRESS** with the IP address of the folder to mount and **PATH** with the path of the folder to mount
- Change **PATH-TO-MOUNT** with the path of the local folder in which to mount the remote folder
- Change **USERNAME-HERE** and **PASSWOR-HERE** to the correct `samba` account username and password

For example, suppose that:
the remote IP is `127.1.1.1` and the remote folder path is `/Downloads`. The local path is `/DATA/Downloads`. And the account to log in via **samba** has the username `admin` and the password `pswd`.
  
Then the first line of mount will have to be modified as follows:

**BEFORE**
```sh
sudo mount -t cifs //IP-ADDRESS/PATH /PATH-TO-MOUNT -o username=USERNAME-HERE,password=PASSWOR-HERE,vers=3.0,rw,uid=1000,gid=1000,forceuid,forcegid,file_mode=0777,dir_mode=0777,nounix
```

**AFTER**
```sh
sudo mount -t cifs //127.1.1.1/Downloads /DATA/Downloads -o username=admin,password=pswd,vers=3.0,rw,uid=1000,gid=1000,forceuid,forcegid,file_mode=0777,dir_mode=0777,nounix
```

Now that the basic changes have been made to the script we can proceed with its execution.

## START THE SCRIPT AT BOOT
To start the script at system startup, a couple of steps are enough.

- Save the script to an appropriate location on your system, such as `/usr/local/bin/mounter.sh`, and make it executable with the command sudo `chmod +x /usr/local/bin/mounter.sh`
- Create a service file called mounter.service in /etc/systemd/system/: `sudo nano /etc/systemd/system/mounter.service`
- Inside this file, insert the following content:

```ini
[Unit]
Description=Mount Retry Script

[Service]
Type=oneshot
ExecStart=/usr/local/bin/mounter.sh

[Install]
WantedBy=multi-user.target
```

- enable the service to start during boot: `sudo systemctl enable mounter.service`

Now when the system starts the folders will be mounted automatically and if the process fails the system will continue to make an attempt every 30 seconds.








