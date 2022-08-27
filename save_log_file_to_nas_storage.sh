#!/usr/bin/bash
#
#Author: Jojo Jaballas
#
#Usage: ./save_log_file_to_nas_storage.sh
#
#
#Description: Script to upload stress test output to pbs_logs share
#
#Date: 08/22/22
#
#Version: 0.0  - Start writing script
#         0.1  - moving credentials from script to file
#         1.0  - moving identifyable information to files instead of from the script
# 
#VARS
SJSTORAGEIP=$(cat nas_ip.txt)
NAS_USER=$(cat nas_user.txt
CUST_FOLDER=$(cat cust_folder.txt)
SERIAL=$(dmidecode -t system|grep "Serial Number:"|awk '{print $3}')
TODAYSDATE=$(date +"%m_%d_%Y")
NUM_LOG_FILES=$(ls -l cpu_stress_$TODAYSDATE*|wc -l)

if [ $NUM_LOG_FILES -gt 1 ]; then
   echo "Log files found that was run today."
   ls cpu_stress_$TODAYSDATE*
   echo
   read -p "There are more than one log files that was run today. Please select which one you would like to save: " LOG_FILE
else
   LOG_FILE=$(ls cpu_stress_$TODAYSDATE*)
fi   

#rename output file to identifiable name (by serial)
mv $LOG_FILE $SERIAL-$LOG_FILE
  
#Install sshpass, if not installed, for passwordless non-scp/ssh  to pbs_logs share
if ! [ $(which sshpass) ]; then
     echo "Installing sshpass for non-interactive ssh/scp..."
    apt-get update
    apt-get install sshpass -y
fi

#create folder on share for server using serial number
echo "Creating folder (by serial number) on sj-storage..."
sshpass -f .creds ssh -o StrictHostKeyChecking=no -l $NAS_USER $SJSTORAGEIP "mkdir /mnt/tank/pbs/pbsv4/pbs_logs/$CUST_FOLDER/$SERIAL"

#copy over log file on sj-storage share
echo "scp $SERIAL-$LOG_FILE $NAS_USER@$SJSTORAGEIP:/mnt/tank/pbs/pbsv4/pbs_logs/$CUST_FOLDER/$SERIAL/"
sshpass -f .creds scp -o StrictHostKeyChecking=no $SERIAL-$LOG_FILE $NAS_USER@$SJSTORAGEIP:/mnt/tank/pbs/pbsv4/pbs_logs/Zoox/$SERIAL/

echo -e -n "\n\nSuccessfully saved stress output to https://$SJSTORAGEIP/pbsv4/pbs_logs/$CUST_FOLDER/$SERIAL/\n"
