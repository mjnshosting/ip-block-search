#!/bin/bash

#This is seperated because of the time it would take to run this command on some devices.
#This will get all the routes and from each device in the device list and prepare
#it for the free-ip.sh script to extract the necessary information. You can run this once
#and then run the free-ip script as many times for as many blocks as you want.

now=$(date +%T.%N)
echo -e "\n"
echo "START: $now"
echo "Make sure the .cloginrc file is in the same directory you are running this script."
echo -e "This really should only be ran once. The free-ip.sh script can be ran multiple times\nwith different /16 blocks"

mkdir route > /dev/null 2>&1

#Collect routing tables, add device prefix, then format further for later
while read devices
       do (
               /usr/local/rancid/bin/clogin -c "sh ip route" $devices > route/$devices-raw.txt
               sed -e "s/^/$devices:/" route/$devices-raw.txt > route/$devices-route.txt
       )
done < device-list

#Cleanup unnecessary files
rm route/*-raw.txt

#Print STOP time.
now=$(date +%T.%N)
echo -e "\n"
echo "STOP: $now"
echo -e "\n"
echo -e "Please investigate the following TIMEOUTs since a timeout usually means that there\nwas no data collected!"
grep -i timeout route/*
