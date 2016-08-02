#!/bin/bash
now=$(date +%T.%N)
echo -e "\n"
echo "START: $now"
echo "Make sure the .cloginrc file is in the same directory you are running this script."
echo -e "Please run collect-route.sh first to get the routing table data from all devices listed\nin the *devices-list* file."

#No need to make these variabiables static anymore.
oct1=$1
oct2=$2
oct3_start=$3
oct3_end=$4

#Create new folders or just clear old information.
mkdir blocks > /dev/null 2>&1
mkdir results > /dev/null 2>&1
rm blocks/*-block.txt > /dev/null 2>&1
rm results/$oct1-$oct2-$oct3_start-to-$oct3_end-free-ip-* > /dev/null 2>&1

#Find your blocks from the ip route.
for (( c=$oct3_start; c<=$oct3_end; c++ ))
        do (
                cat route/*-route.txt | grep "$oct1.$oct2.$c" | grep "C\|S\|L" | sed -e "s/,/:/" | sort -u -o blocks/$oct1.$oct2.$c-block.txt
        ) done

#Read line in -block.txt file, get device and interface name, lookup customer name, then output to a file.
for (( c=$oct3_start; c<=$oct3_end; c++ ))
        do (
                while IFS=: read device route interface
                        do (
                                if [ "$interface" == "" ]
                                then
                                        int_desc="!!Please Investigate Manually!!"
                                        interface="!!Please Investigate Manually!!"
                                else
                                        int_desc=$(/usr/local/rancid/bin/clogin -t 10 -c "sh run int $interface | i escription" $device | grep "description \|Description" | sed -e "s/description/ /" -e "s/Description/ /" -e "s/^[ \t]*//")
                                fi
                        echo "On $device $interface route $route belongs to customer $int_desc" >> results/$oct1-$oct2-$oct3_start-to-$oct3_end-free-ip-results.txt
                        )
                done < blocks/$oct1.$oct2.$c-block.txt
        ) done

#Remove the ^M character from the file because it causes issues when cat'ng the file.
#For some reason this has to be ran twice to get rid of all occurences.
ex -bsc '%s/\r//|x' results/$oct1-$oct2-$oct3_start-to-$oct3_end-free-ip-results.txt
ex -bsc '%s/\r//|x' results/$oct1-$oct2-$oct3_start-to-$oct3_end-free-ip-results.txt
cat results/$oct1-$oct2-$oct3_start-to-$oct3_end-free-ip-results.txt | tr -s " \t" | sort -u -k6 -o results/$oct1-$oct2-$oct3_start-to-$oct3_end-free-ip-report.txt

#Print STOP time.
now=$(date +%T.%N)
echo -e "\n"
echo "STOP: $now"
