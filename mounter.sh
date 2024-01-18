#!/bin/bash

# Save the script to an appropriate location on your system, such as /usr/local/bin/mounter.sh, and make it executable with the command sudo chmod +x /usr/local/bin/mounter.sh

# Create a systemd service to run the script on boot. For example, create a service file called mounter.service in /etc/systemd/system/:
# sudo nano /etc/systemd/system/mounter.service

# Inside this file, insert the following content:
# [Unit]
# Description=Mount Retry Script

# [Service]
# Type=oneshot
# ExecStart=/usr/local/bin/mounter.sh

# [Install]
# WantedBy=multi-user.target

# enable the service to start during boot:
# sudo systemctl enable mounter.service

downMount=0
moviesMount=0
seriesMount=0

# Loop to attempt editing at 30 second intervals
# Replace the objects in brackets with the appropriate location of your NAS and the path you would like to mount the folder
while true; do

    if [ $downMount -eq 0 ]; then
        sudo mount -t cifs [//IP-ADDRESS/PATH] [/PATH-TO-MOUNT default: /DATA/Downloads] -o username=USERNAME-HERE,password=PASSWORD-HERE,vers=3.0,rw,uid=1000,gid=1000,forceuid,forcegid,file_mode=0777,dir_mode=0777,nounix

        if [ $? -eq 0 ]; then
            echo "downloads mount successful!"
            downMount=1
        fi
    
    fi

    if [ $moviesMount -eq 0 ]; then
        sudo mount -t cifs [//IP-ADDRESS/PATH] [/PATH-TO-MOUNT default: /DATA/Media/Movies] -o username=USERNAME-HERE,password=PASSWORD-HERE,vers=3.0,rw,uid=1000,gid=1000,forceuid,forcegid,file_mode=0777,dir_mode=0777,nounix

        if [ $? -eq 0 ]; then
            echo "movies mount successful!"
            moviesMount=1
        fi
    
    fi

    if [ $seriesMount -eq 0 ]; then
        sudo mount -t cifs [//IP-ADDRESS/PATH] [/PATH-TO-MOUNT default: /DATA/Media/TV\ Shows] -o username=USERNAME-HERE,password=PASSWORD-HERE,vers=3.0,rw,uid=1000,gid=1000,forceuid,forcegid,file_mode=0777,dir_mode=0777,nounix

        if [ $? -eq 0 ]; then
            echo "shows mount successful!"
            seriesMount=1
        fi
    
    fi
    
    # If all mounts were successful, exit the loop
    if [[ $downMount -eq 1 && $moviesMount -eq 1 && $seriesMount -eq 1 ]]; then
        echo "All mounts successful!"
        break
    fi
    
    # Please wait 30 seconds before trying again
    echo "An error has occurred, retrying in 30secs"
    sleep 30
done
echo "Done!"
